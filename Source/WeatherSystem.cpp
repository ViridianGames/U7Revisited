#include "WeatherSystem.h"
#include "U7Globals.h"
#include "U7Object.h"
#include "U7Player.h"
#include "Geist/Logging.h"
#include "Geist/SoundSystem.h"
#include "Geist/Engine.h"
#include "Geist/Config.h"
#include "Geist/Globals.h"
#include "Geist/ScriptingSystem.h"
#include "rlgl.h"
#include "raymath.h"
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <array>

std::unique_ptr<WeatherSystem> g_WeatherSystem;

namespace
{
	constexpr float kFlashDuration = 0.12f;
	// Daylight multiply at full overcast fade (1 = no dim). Lower = darker.
	// Was a flat 0.42 (~58% darker) — too heavy for light rain; now intensity-scaled and lighter overall.
	constexpr int kOvercastVeilAlpha = 55; // was 70; intensity scale applied on top
	constexpr float kFogDimR = 0.55f;
	constexpr float kFogDimG = 0.60f;
	constexpr float kFogDimB = 0.68f;
	constexpr int kFogVeilAlpha = 150;

	float FogIntensityScale(WeatherIntensity intensity)
	{
		switch (intensity)
		{
		case WeatherIntensity::Light:  return 0.55f;
		case WeatherIntensity::Heavy:  return 1.35f;
		case WeatherIntensity::Medium:
		default:                       return 1.0f;
		}
	}

	// Lighting multiply at full fade: Light drizzle barely dims; keep Heavy shy of old 0.42.
	float OvercastDimMultiplier(WeatherIntensity intensity)
	{
		switch (intensity)
		{
		case WeatherIntensity::Light:  return 0.90f; // ~10% darker
		case WeatherIntensity::Heavy:  return 0.70f; // ~30% darker (was 0.55 / flat 0.42)
		case WeatherIntensity::Medium:
		default:                       return 0.80f; // ~20% darker
		}
	}

	Color LerpSkyColor(Color a, Color b, float t)
	{
		t = std::clamp(t, 0.0f, 1.0f);
		return Color{
			static_cast<unsigned char>(a.r + (b.r - a.r) * t),
			static_cast<unsigned char>(a.g + (b.g - a.g) * t),
			static_cast<unsigned char>(a.b + (b.b - a.b) * t),
			static_cast<unsigned char>(a.a + (b.a - a.a) * t)
		};
	}

	Color ScaleSkyColor(Color c, float mul)
	{
		mul = std::clamp(mul, 0.0f, 1.5f);
		return Color{
			static_cast<unsigned char>(std::clamp(static_cast<int>(c.r * mul), 0, 255)),
			static_cast<unsigned char>(std::clamp(static_cast<int>(c.g * mul), 0, 255)),
			static_cast<unsigned char>(std::clamp(static_cast<int>(c.b * mul), 0, 255)),
			c.a
		};
	}

	float OvercastVeilScale(WeatherIntensity intensity)
	{
		switch (intensity)
		{
		case WeatherIntensity::Light:  return 0.40f;
		case WeatherIntensity::Heavy:  return 0.95f;
		case WeatherIntensity::Medium:
		default:                       return 0.65f;
		}
	}

	// Continuous wind uses WindUnitWX/WZ: 0° = N (-Z), wx=sin(yaw), wz=-cos(yaw).

	constexpr float kSkyCloudFadeInSec = 3.0f;

	// Weather 10 celestial constants
	constexpr float kCelestialRadius = 110.0f; // just inside dome (120)
	constexpr float kSiderealDegPerHour = 15.0f;
	constexpr float kMonthlyStarDriftDeg = 2.5f;
	constexpr float kCelestialPoleTiltDeg = 55.0f; // angle from zenith → mid-latitude rise/set
	// Dome skirt fills sky below world-horizontal (draw only). Celestial lip is el=0.
	constexpr float kSkySkirtDeg = 22.0f;
	constexpr int kStarCount = 118;
	constexpr float kWorldHorizonDeg = 0.0f;
	// Golden hour / amber: 4° → 0° at dusk/dawn lips; linear warmth.
	constexpr float kSunGoldenElDeg = 4.0f;
	constexpr float kSunWarmthElDeg = kSunGoldenElDeg;
	constexpr float kMoonWarmthElDeg = 15.0f;
	constexpr float kPlanetRadius = 0.22f;
	constexpr float kSunDiscRadius = 3.6f;
	constexpr float kSunHaloRadius = 7.5f;
	constexpr float kSunAngularRadiusDeg = (kSunDiscRadius / kCelestialRadius) * (180.0f / PI);
	constexpr float kSunPeakElDeg = 68.0f;
	constexpr float kSunDayCoreStartHour = kDawnEndHour;   // 7:00
	constexpr float kSunDayCoreEndHour = kDuskStartHour; // 20:00
	// Phase only: golden at dusk/dawn lips; rate 12°/h (clarity hours unchanged).
	constexpr float kDuskSunSetHour =
		kDuskStartHour + kSunGoldenElDeg / kSunTwilightElRateDegPerHour; // ~20:20
	constexpr float kDawnSunRiseHour =
		kDawnEndHour - kSunGoldenElDeg / kSunTwilightElRateDegPerHour;   // ~6:40
	constexpr float kSunAzRateDegPerHour = 10.0f;
	constexpr float kSunDayAz0 = 115.0f; // 7:00 at golden
	constexpr float kSunDayAz1 = 245.0f; // 20:00 at golden
	// Pre-dawn climb from skirt so el=0 at geometric rise (same rate).
	constexpr float kDawnSkirtStartHour =
		kDawnSunRiseHour - (kSkySkirtDeg / kSunTwilightElRateDegPerHour);
	constexpr float kDuskSkirtEndHour =
		kDuskSunSetHour + (kSkySkirtDeg / kSunTwilightElRateDegPerHour);
	// Modelo A moons: calendar owns phase; geometry places vs sun with personality offsets.
	constexpr float kTrammelAzBiasDeg = 14.0f;
	constexpr float kFeluccaAzBiasDeg = -18.0f;
	constexpr float kTrammelInclPersonalityDeg = 10.0f;
	constexpr float kFeluccaInclPersonalityDeg = -12.0f;
	constexpr float kTrammelMoonRadius = 3.2f;
	constexpr float kFeluccaMoonRadius = 2.1f;
	constexpr float kMoonAltitudeVisDeg = 8.0f; // softstep 0→1 above geometric horizon
	constexpr float kTrammelLightWeight = 0.70f;
	constexpr float kFeluccaLightWeight = 0.65f * 0.45f; // preserve prior combined weight
	constexpr float kSkyLumNight = 0.08f;
	constexpr float kSkyLumDay = 1.0f;
	constexpr float kContrastSoft = 0.22f;

	// Exult UI_set_orrery offsets[state 0..9][planet frame 0..7] = {dx, dy} tiles.
	constexpr short kOrreryOffsets[10][8][2] = {
		/* S0 */ {{2, -3}, {3, -3}, {1, -6}, {6, -2}, {7, -1}, {8, 1}, {-4, 8}, {9, -2}},
		/* S1 */ {{3, -1}, {4, -1}, {-5, -3}, {3, 6}, {7, 2}, {4, 7}, {-8, 4}, {8, 5}},
		/* S2 */ {{3, 1}, {3, 2}, {-3, 4}, {-5, 4}, {2, 7}, {-2, 8}, {-9, 1}, {2, 9}},
		/* S3 */ {{1, 3}, {1, 4}, {4, 3}, {-5, -3}, {-4, 6}, {-7, 4}, {-9, -1}, {-4, 9}},
		/* S4 */ {{-2, 3}, {-2, 4}, {5, -2}, {5, -4}, {-7, 2}, {-8, 1}, {-8, -4}, {-8, 6}},
		/* S5 */ {{-4, 1}, {-5, 1}, {-5, -3}, {6, 3}, {-7, -2}, {-7, -4}, {-7, -6}, {-10, 1}},
		/* S6 */ {{-4, 9}, {-5, -1}, {-3, 4}, {-3, 6}, {-6, -4}, {-5, -6}, {-7, -6}, {-10, -2}},
		/* S7 */ {{-4, 2}, {-4, -3}, {4, 3}, {-6, 1}, {-5, -5}, {-3, -7}, {-4, -8}, {-8, -6}},
		/* S8 */ {{-3, -3}, {-3, -4}, {5, -2}, {-3, -5}, {-1, -7}, {0, -8}, {-1, -9}, {-5, -9}},
		/* S9 */ {{0, -4}, {0, -5}, {1, -6}, {1, -6}, {1, -7}, {1, -8}, {1, -9}, {-1, -10}}
	};

	constexpr Color kPlanetColors[8] = {
		{180, 200, 255, 255}, // Honesty-ish pale blue
		{120, 180, 255, 255},
		{220, 140, 90, 255},
		{200, 80, 70, 255},
		{90, 200, 110, 255},
		{200, 160, 60, 255},  // ringed / honor warm
		{160, 100, 200, 255},
		{210, 210, 220, 255}
	};

	// Felucca phase index 0..7 per day-of-month 1..28 (Codex / U5 table).
	constexpr int kFeluccaPhaseByDay[28] = {
		0, 1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7,
		0, 1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7
	};

	float DegToRad(float deg) { return deg * (PI / 180.0f); }
	float RadToDeg(float rad) { return rad * (180.0f / PI); }

	// Same ramp as DrawSkyHemisphere stacks: t=0 at skirt bottom, t=1 at zenith.
	Color SkyGradientColorAtStackT(Color zenith, Color mid, Color horizon, float t)
	{
		const float skirtRad = DegToRad(kSkySkirtDeg);
		const float latSpan = (PI * 0.5f) - (-skirtRad);
		const float tEquator = skirtRad / latSpan;
		t = std::clamp(t, 0.0f, 1.0f);
		if (t <= tEquator)
		{
			return horizon;
		}
		const float u = (t - tEquator) / std::max(1.0e-4f, 1.0f - tEquator);
		if (u <= 0.5f)
		{
			return LerpSkyColor(horizon, mid, u * 2.0f);
		}
		return LerpSkyColor(mid, zenith, (u - 0.5f) * 2.0f);
	}

	Color SkyGradientColorAtElevationDeg(Color zenith, Color mid, Color horizon, float elevationDeg)
	{
		const float skirtRad = DegToRad(kSkySkirtDeg);
		const float latMin = -skirtRad;
		const float latSpan = (PI * 0.5f) - latMin;
		const float t = (DegToRad(elevationDeg) - latMin) / latSpan;
		return SkyGradientColorAtStackT(zenith, mid, horizon, t);
	}

	float Smoothstep(float edge0, float edge1, float x)
	{
		if (edge1 <= edge0)
		{
			return x >= edge1 ? 1.0f : 0.0f;
		}
		const float t = std::clamp((x - edge0) / (edge1 - edge0), 0.0f, 1.0f);
		return t * t * (3.0f - 2.0f * t);
	}

	float SiderealYawDeg()
	{
		// Continuous seasonal drift via official g_britannianDayIndex (no month-step jumps).
		const double hours = static_cast<double>(GetSmoothClockHours());
		const double totalDays =
			static_cast<double>(g_britannianDayIndex) + hours / 24.0;
		const double yaw =
			hours * static_cast<double>(kSiderealDegPerHour)
			+ totalDays * (static_cast<double>(kMonthlyStarDriftDeg) / 28.0);
		return static_cast<float>(std::fmod(yaw, 360.0));
	}

	int TrammelPhaseIndexForDay(int day1to28)
	{
		const int day = std::clamp(day1to28, 1, 28);
		return std::max(0, (day + 8) % 9 - 1); // 0..7
	}

	int FeluccaPhaseIndexForDay(int day1to28)
	{
		const int day = std::clamp(day1to28, 1, 28);
		return kFeluccaPhaseByDay[day - 1];
	}

	int TrammelPhaseIndex()
	{
		return TrammelPhaseIndexForDay(static_cast<int>(std::max(1u, g_dayOfMonth)));
	}

	int FeluccaPhaseIndex()
	{
		return FeluccaPhaseIndexForDay(static_cast<int>(std::clamp(g_dayOfMonth, 1u, 28u)));
	}

	void NextBritannianCalendarDay(unsigned int month, unsigned int day,
		unsigned int& outMonth, unsigned int& outDay)
	{
		outMonth = std::clamp(month, 1u, 12u);
		outDay = std::clamp(day, 1u, 28u) + 1u;
		if (outDay > 28u)
		{
			outDay = 1u;
			++outMonth;
			if (outMonth > 12u)
			{
				outMonth = 1u;
			}
		}
	}

	float NormalizeDeg360(float deg)
	{
		deg = std::fmod(deg, 360.0f);
		if (deg < 0.0f)
		{
			deg += 360.0f;
		}
		return deg;
	}

	// Azimuth matching SkyDirFromAzEl: 0=+Z (N), 90=+X (E).
	float AzimuthDegFromDir(Vector3 dir)
	{
		const float flatSq = dir.x * dir.x + dir.z * dir.z;
		if (flatSq < 1.0e-8f)
		{
			return 0.0f;
		}
		return NormalizeDeg360(RadToDeg(std::atan2(dir.x, dir.z)));
	}

	float ShortestAzDeltaDeg(float a0, float a1)
	{
		float d = NormalizeDeg360(a1) - NormalizeDeg360(a0);
		if (d > 180.0f)
		{
			d -= 360.0f;
		}
		else if (d < -180.0f)
		{
			d += 360.0f;
		}
		return d;
	}

	// Warm band vs view elevation: continuous through el=0 and −22° skirt.
	float WarmHorizonWeight(float viewElDeg)
	{
		// Knots: −22 → 0.35, 0 → 1, +15 → 0.45, +45 → 0.
		if (viewElDeg <= -kSkySkirtDeg)
		{
			return 0.35f;
		}
		if (viewElDeg < 0.0f)
		{
			const float t = (viewElDeg - (-kSkySkirtDeg)) / kSkySkirtDeg;
			return 0.35f + (1.0f - 0.35f) * std::clamp(t, 0.0f, 1.0f);
		}
		if (viewElDeg < 15.0f)
		{
			const float t = viewElDeg / 15.0f;
			return 1.0f + (0.45f - 1.0f) * std::clamp(t, 0.0f, 1.0f);
		}
		if (viewElDeg < 45.0f)
		{
			const float t = (viewElDeg - 15.0f) / 30.0f;
			return 0.45f * (1.0f - std::clamp(t, 0.0f, 1.0f));
		}
		return 0.0f;
	}

	// Sun elevation twilight window ≈ [−10°, +8°], peak near 0°.
	float WarmSolarWeight(float sunElDeg)
	{
		if (sunElDeg <= -10.0f || sunElDeg >= 8.0f)
		{
			return 0.0f;
		}
		if (sunElDeg < 0.0f)
		{
			return Smoothstep(-10.0f, 0.0f, sunElDeg);
		}
		return 1.0f - Smoothstep(0.0f, 8.0f, sunElDeg);
	}

	// Cubic Hermite: p(0)=p0, p(1)=p1, p'(0)=m0, p'(1)=m1 (derivatives wrt t).
	float Hermite1D(float t, float p0, float p1, float m0, float m1)
	{
		t = std::clamp(t, 0.0f, 1.0f);
		const float t2 = t * t;
		const float t3 = t2 * t;
		return (2.0f * t3 - 3.0f * t2 + 1.0f) * p0
			+ (t3 - 2.0f * t2 + t) * m0
			+ (-2.0f * t3 + 3.0f * t2) * p1
			+ (t3 - t2) * m1;
	}

	// Calendar phase 0..7 → full-cycle angle 0..315° (not astronomical elongation 0..180).
	float PhaseCycleAngleDeg(int phase0to7)
	{
		return static_cast<float>(std::clamp(phase0to7, 0, 7)) * 45.0f;
	}

	float LerpAngleCircularDeg(float a0, float a1, float t)
	{
		a0 = NormalizeDeg360(a0);
		a1 = NormalizeDeg360(a1);
		float delta = a1 - a0;
		if (delta > 180.0f)
		{
			delta -= 360.0f;
		}
		else if (delta < -180.0f)
		{
			delta += 360.0f;
		}
		return NormalizeDeg360(a0 + delta * std::clamp(t, 0.0f, 1.0f));
	}

	// 0 = new … 1 = full from cycle angle (cos-symmetric about full).
	float IlluminationFromCycleAngleDeg(float cycleAngleDeg)
	{
		const float c = std::cos(DegToRad(cycleAngleDeg));
		return std::clamp(0.5f * (1.0f - c), 0.0f, 1.0f);
	}

	float PhaseIllumination(int phase0to7)
	{
		return IlluminationFromCycleAngleDeg(PhaseCycleAngleDeg(phase0to7));
	}

	// Smooth cycle angle between today's and tomorrow's table indices (incl. 28→1).
	float SmoothPhaseCycleAngleDeg(bool trammel)
	{
		const unsigned int month = std::clamp(g_month, 1u, 12u);
		const unsigned int day = std::clamp(g_dayOfMonth, 1u, 28u);
		unsigned int nextMonth = month;
		unsigned int nextDay = day;
		NextBritannianCalendarDay(month, day, nextMonth, nextDay);

		const int i0 = trammel ? TrammelPhaseIndexForDay(static_cast<int>(day))
			: FeluccaPhaseIndexForDay(static_cast<int>(day));
		const int i1 = trammel ? TrammelPhaseIndexForDay(static_cast<int>(nextDay))
			: FeluccaPhaseIndexForDay(static_cast<int>(nextDay));

		const float fracDay = std::clamp(GetSmoothClockHours() / 24.0f, 0.0f, 1.0f);
		return LerpAngleCircularDeg(PhaseCycleAngleDeg(i0), PhaseCycleAngleDeg(i1), fracDay);
	}

	// SplitMix-ish — breaks sequential cord patterns better than a single multiply.
	float Hash01(int n)
	{
		std::uint32_t x = static_cast<std::uint32_t>(n) * 0x9E3779B9u;
		x ^= x >> 16;
		x *= 0x85EBCA6Bu;
		x ^= x >> 13;
		x *= 0xC2B2AE35u;
		x ^= x >> 16;
		return static_cast<float>(x & 0xFFFFFF) / static_cast<float>(0xFFFFFF);
	}

	float Hash01(int a, int b)
	{
		return Hash01(a * 73856093 ^ b * 19349663);
	}

	void SunAzElFromClock(float clockHours, float& outAz, float& outEl);
	Vector3 EquatorialDir(float raDeg, float decDeg);
	Vector3 RotateCelestial(Vector3 restDir, float siderealDeg);
	Vector3 CelestialPoleAxis();
	Vector3 RotateAroundAxis(Vector3 v, Vector3 axis, float angleRad);
	float ElevationDegFromDir(Vector3 dir);

	struct MoonState
	{
		Vector3 dir{ 0.0f, 1.0f, 0.0f };
		float elevationDeg = 0.0f;
		float cycleAngleDeg = 0.0f;
		float illumination = 0.0f;
		float altitudeVis = 0.0f; // 0 below geometric horizon → 1 above soft band
		float radius = 2.0f;
	};

	float MoonAltitudeVis(float elevationDeg)
	{
		return Smoothstep(0.0f, kMoonAltitudeVisDeg, elevationDeg);
	}

	// Place moon vs sun: separation matches illum; sign from waxing/waning; personality bias/incl.
	Vector3 PlaceMoonDirVsSun(Vector3 sunDir, float cycleAngleDeg, float azBiasDeg, float inclPersonalityDeg)
	{
		const float illum = IlluminationFromCycleAngleDeg(cycleAngleDeg);
		const float sepDeg = RadToDeg(std::acos(std::clamp(1.0f - 2.0f * illum, -1.0f, 1.0f)));
		const float cycle = NormalizeDeg360(cycleAngleDeg);
		const float signedSep = ((cycle <= 180.0f) ? sepDeg : -sepDeg) + azBiasDeg;

		const Vector3 pole = CelestialPoleAxis();
		Vector3 dir = RotateAroundAxis(sunDir, pole, DegToRad(signedSep));
		dir = Vector3Normalize(dir);
		// Inclination personality: lift/sink along pole without collapsing to a point.
		dir = Vector3Normalize(Vector3Add(
			dir,
			Vector3Scale(pole, std::sin(DegToRad(inclPersonalityDeg)) * 0.40f)));
		return dir;
	}

	void EvaluateMoon(bool trammel, Vector3 sunDir, MoonState& out)
	{
		out.cycleAngleDeg = SmoothPhaseCycleAngleDeg(trammel);
		out.illumination = IlluminationFromCycleAngleDeg(out.cycleAngleDeg);
		out.radius = trammel ? kTrammelMoonRadius : kFeluccaMoonRadius;
		out.dir = PlaceMoonDirVsSun(
			sunDir,
			out.cycleAngleDeg,
			trammel ? kTrammelAzBiasDeg : kFeluccaAzBiasDeg,
			trammel ? kTrammelInclPersonalityDeg : kFeluccaInclPersonalityDeg);
		out.elevationDeg = ElevationDegFromDir(out.dir);
		out.altitudeVis = MoonAltitudeVis(out.elevationDeg);
	}

	void EvaluateMoons(Vector3 sunDir, MoonState& outTrammel, MoonState& outFelucca)
	{
		EvaluateMoon(true, sunDir, outTrammel);
		EvaluateMoon(false, sunDir, outFelucca);
	}

	float SkyLuminance(float dayAmount)
	{
		return kSkyLumNight + (kSkyLumDay - kSkyLumNight) * std::clamp(dayAmount, 0.0f, 1.0f);
	}

	// Intrinsic body luminance vs sky → visibility (body does not lose power; sky washes it out).
	float BodyContrastVis(float bodyIntrinsicLum, float skyLum)
	{
		bodyIntrinsicLum = std::clamp(bodyIntrinsicLum, 0.0f, 1.5f);
		return Smoothstep(skyLum, skyLum + kContrastSoft, bodyIntrinsicLum);
	}

	// Rest-frame direction: az 0=+Z (N), 90=+X (E); el -90..+90.
	Vector3 SkyDirFromAzEl(float azDeg, float elDeg)
	{
		const float el = DegToRad(std::clamp(elDeg, -89.0f, 89.0f));
		const float az = DegToRad(azDeg);
		const float cosEl = std::cos(el);
		return Vector3Normalize(Vector3{
			cosEl * std::sin(az),
			std::sin(el),
			cosEl * std::cos(az)
		});
	}

	Vector3 CelestialPoleAxis()
	{
		const float tilt = DegToRad(kCelestialPoleTiltDeg);
		return Vector3Normalize(Vector3{ 0.0f, std::cos(tilt), std::sin(tilt) });
	}

	Vector3 RotateAroundAxis(Vector3 v, Vector3 axis, float angleRad)
	{
		const float c = std::cos(angleRad);
		const float s = std::sin(angleRad);
		const Vector3 axisN = Vector3Normalize(axis);
		const float d = Vector3DotProduct(axisN, v);
		return Vector3Add(
			Vector3Add(Vector3Scale(v, c), Vector3Scale(Vector3CrossProduct(axisN, v), s)),
			Vector3Scale(axisN, d * (1.0f - c)));
	}

	Vector3 RotateCelestial(Vector3 restDir, float siderealDeg)
	{
		return Vector3Normalize(RotateAroundAxis(restDir, CelestialPoleAxis(), DegToRad(siderealDeg)));
	}

	float ElevationDegFromDir(Vector3 dir)
	{
		return RadToDeg(std::asin(std::clamp(dir.y, -1.0f, 1.0f)));
	}

	Vector3 SkyWorldPosFromDir(Camera camera, Vector3 dir)
	{
		return Vector3Add(camera.position, Vector3Scale(Vector3Normalize(dir), kCelestialRadius));
	}

	bool BillboardBasis(Camera camera, Vector3 worldPos, Vector3& outRight, Vector3& outUp)
	{
		Vector3 toCam = Vector3Subtract(camera.position, worldPos);
		if (Vector3LengthSqr(toCam) < 0.0001f)
		{
			return false;
		}
		toCam = Vector3Normalize(toCam);
		Vector3 right = Vector3CrossProduct(camera.up, toCam);
		if (Vector3LengthSqr(right) < 0.0001f)
		{
			right = Vector3CrossProduct(Vector3{ 0, 0, 1 }, toCam);
		}
		if (Vector3LengthSqr(right) < 0.0001f)
		{
			return false;
		}
		outRight = Vector3Normalize(right);
		outUp = Vector3Normalize(Vector3CrossProduct(toCam, outRight));
		return true;
	}

	void DrawCelestialDisc(Camera camera, Vector3 worldPos, float radius, Color color, int segments = 12)
	{
		if (color.a < 1 || radius <= 0.01f)
		{
			return;
		}
		Vector3 right{}, up{};
		if (!BillboardBasis(camera, worldPos, right, up))
		{
			return;
		}

		rlBegin(RL_TRIANGLES);
		for (int i = 0; i < segments; ++i)
		{
			const float a0 = (static_cast<float>(i) / static_cast<float>(segments)) * (2.0f * PI);
			const float a1 = (static_cast<float>(i + 1) / static_cast<float>(segments)) * (2.0f * PI);
			const Vector3 p0 = Vector3Add(worldPos,
				Vector3Add(Vector3Scale(right, std::cos(a0) * radius), Vector3Scale(up, std::sin(a0) * radius)));
			const Vector3 p1 = Vector3Add(worldPos,
				Vector3Add(Vector3Scale(right, std::cos(a1) * radius), Vector3Scale(up, std::sin(a1) * radius)));
			rlColor4ub(color.r, color.g, color.b, color.a);
			rlVertex3f(worldPos.x, worldPos.y, worldPos.z);
			rlColor4ub(color.r, color.g, color.b, color.a);
			rlVertex3f(p0.x, p0.y, p0.z);
			rlColor4ub(color.r, color.g, color.b, color.a);
			rlVertex3f(p1.x, p1.y, p1.z);
		}
		rlEnd();
	}

	// Moon phase as lit disc region (crescent / quarter / gibbous) — not a pizza wedge.
	// illum 0=new … 1=full. lightAngleRad rotates billboard so +X faces the sun projection.
	void DrawCelestialMoonPhase(Camera camera, Vector3 worldPos, float radius, Color litColor,
		float illum, float lightAngleRad, Color softShade, int strips = 24)
	{
		illum = std::clamp(illum, 0.0f, 1.0f);
		if (radius <= 0.01f)
		{
			return;
		}
		Vector3 right{}, up{};
		if (!BillboardBasis(camera, worldPos, right, up))
		{
			return;
		}

		const float lc = std::cos(lightAngleRad);
		const float ls = std::sin(lightAngleRad);
		const Vector3 lightRight = Vector3Add(Vector3Scale(right, lc), Vector3Scale(up, ls));
		const Vector3 lightUp = Vector3Add(Vector3Scale(right, -ls), Vector3Scale(up, lc));

		auto point = [&](float x, float y) {
			return Vector3Add(worldPos,
				Vector3Add(Vector3Scale(lightRight, x), Vector3Scale(lightUp, y)));
		};

		// Optional soft unlit disc (night only — caller passes a≈0 by day).
		if (softShade.a > 0)
		{
			DrawCelestialDisc(camera, worldPos, radius, softShade, 16);
		}

		if (litColor.a < 1 || illum < 0.03f)
		{
			return;
		}

		// Lit from terminator → +X (sun side) in the rotated light frame.
		rlBegin(RL_TRIANGLES);
		for (int i = 0; i < strips; ++i)
		{
			const float t0 = -1.0f + 2.0f * static_cast<float>(i) / static_cast<float>(strips);
			const float t1 = -1.0f + 2.0f * static_cast<float>(i + 1) / static_cast<float>(strips);
			const float y0 = t0 * radius;
			const float y1 = t1 * radius;
			const float xC0 = std::sqrt(std::max(0.0f, radius * radius - y0 * y0));
			const float xC1 = std::sqrt(std::max(0.0f, radius * radius - y1 * y1));
			const float xA0 = (1.0f - 2.0f * illum) * xC0;
			const float xB0 = xC0;
			const float xA1 = (1.0f - 2.0f * illum) * xC1;
			const float xB1 = xC1;
			if (xB0 - xA0 < 0.001f * radius && xB1 - xA1 < 0.001f * radius)
			{
				continue;
			}

			const Vector3 p00 = point(xA0, y0);
			const Vector3 p10 = point(xB0, y0);
			const Vector3 p01 = point(xA1, y1);
			const Vector3 p11 = point(xB1, y1);
			rlColor4ub(litColor.r, litColor.g, litColor.b, litColor.a);
			rlVertex3f(p00.x, p00.y, p00.z);
			rlColor4ub(litColor.r, litColor.g, litColor.b, litColor.a);
			rlVertex3f(p10.x, p10.y, p10.z);
			rlColor4ub(litColor.r, litColor.g, litColor.b, litColor.a);
			rlVertex3f(p11.x, p11.y, p11.z);

			rlColor4ub(litColor.r, litColor.g, litColor.b, litColor.a);
			rlVertex3f(p00.x, p00.y, p00.z);
			rlColor4ub(litColor.r, litColor.g, litColor.b, litColor.a);
			rlVertex3f(p11.x, p11.y, p11.z);
			rlColor4ub(litColor.r, litColor.g, litColor.b, litColor.a);
			rlVertex3f(p01.x, p01.y, p01.z);
		}
		rlEnd();
	}

	float MoonLightAngleOnBillboard(Camera camera, Vector3 moonWorldPos, Vector3 moonDir, Vector3 sunDir)
	{
		Vector3 right{}, up{};
		if (!BillboardBasis(camera, moonWorldPos, right, up))
		{
			return 0.0f;
		}
		// Project sun direction onto the moon billboard plane.
		const Vector3 n = Vector3Normalize(moonDir);
		Vector3 sunFlat = Vector3Subtract(sunDir, Vector3Scale(n, Vector3DotProduct(sunDir, n)));
		if (Vector3LengthSqr(sunFlat) < 1.0e-6f)
		{
			return 0.0f;
		}
		sunFlat = Vector3Normalize(sunFlat);
		return std::atan2(Vector3DotProduct(sunFlat, up), Vector3DotProduct(sunFlat, right));
	}

	// Unit dir in equatorial frame (pole = CelestialPoleAxis), then sidereal spin.
	Vector3 EquatorialDir(float raDeg, float decDeg)
	{
		const Vector3 pole = CelestialPoleAxis();
		// Pick a stable RA=0 reference on the equator.
		Vector3 ref = Vector3CrossProduct(Vector3{ 1.0f, 0.0f, 0.0f }, pole);
		if (Vector3LengthSqr(ref) < 0.001f)
		{
			ref = Vector3CrossProduct(Vector3{ 0.0f, 0.0f, 1.0f }, pole);
		}
		ref = Vector3Normalize(ref);
		const Vector3 east = Vector3Normalize(Vector3CrossProduct(pole, ref));
		const float ra = DegToRad(raDeg);
		const float dec = DegToRad(std::clamp(decDeg, -89.0f, 89.0f));
		const float cd = std::cos(dec);
		return Vector3Normalize(Vector3Add(
			Vector3Add(Vector3Scale(ref, cd * std::cos(ra)), Vector3Scale(east, cd * std::sin(ra))),
			Vector3Scale(pole, std::sin(dec))));
	}

	Color LerpColorRGB(Color a, Color b, float t)
	{
		t = std::clamp(t, 0.0f, 1.0f);
		return Color{
			static_cast<unsigned char>(a.r + (b.r - a.r) * t),
			static_cast<unsigned char>(a.g + (b.g - a.g) * t),
			static_cast<unsigned char>(a.b + (b.b - a.b) * t),
			static_cast<unsigned char>(a.a + (b.a - a.a) * t)
		};
	}

	Color HorizonWarmLit(Color noonLit, Color amberLit, float elevAboveLipDeg, float warmthElDeg)
	{
		// Linear: 1 at lip (amber), 0 at warmthElDeg above (noon).
		const float warmth = 1.0f - Smoothstep(0.0f, warmthElDeg, elevAboveLipDeg);
		return LerpColorRGB(noonLit, amberLit, warmth);
	}

	// Screen sky/ground join for DRAW cull only (iso camera). Not used for sun path/amber
	// (those stay on world el=0). Returns elevation <= 0, within the dome skirt.
	float CameraVisualHorizonDeg(Camera camera)
	{
		Vector3 forward = Vector3Subtract(camera.target, camera.position);
		if (Vector3LengthSqr(forward) < 1.0e-6f)
		{
			return -kSkySkirtDeg * 0.5f;
		}
		forward = Vector3Normalize(forward);
		Vector3 flat{ forward.x, 0.0f, forward.z };
		const float flatLen = Vector3Length(flat);
		if (flatLen < 1.0e-4f)
		{
			return std::clamp(
				RadToDeg(std::asin(std::clamp(forward.y, -1.0f, 1.0f))) * 0.35f,
				-kSkySkirtDeg,
				kWorldHorizonDeg);
		}
		flat = Vector3Scale(flat, 1.0f / flatLen);
		const float height = std::max(0.5f, camera.position.y - camera.target.y);
		const float farDist = std::max(height * 5.0f, 60.0f);
		const Vector3 toFar = Vector3Normalize(Vector3{
			flat.x * farDist,
			-height,
			flat.z * farDist
		});
		const float el = RadToDeg(std::asin(std::clamp(toFar.y, -1.0f, 1.0f)));
		return std::clamp(el, -kSkySkirtDeg, kWorldHorizonDeg);
	}

	// Sun path: day sine; dusk/dawn at ~12°/h through el=0 then skirt (no poof at horizon).
	void SunAzElFromClock(float clockHours, float& outAz, float& outEl)
	{
		float h = std::fmod(clockHours, 24.0f);
		if (h < 0.0f)
		{
			h += 24.0f;
		}

		const float parkEl = -kSkySkirtDeg;
		const float parkAzDawn = kSunDayAz0
			- kSunAzRateDegPerHour * (kDawnEndHour - kDawnSkirtStartHour);
		const float parkAzDusk = kSunDayAz1
			+ kSunAzRateDegPerHour * (kDuskSkirtEndHour - kDuskStartHour);

		// Pre-dawn: climb from skirt toward geometric rise (el=0 at kDawnSunRiseHour).
		if (h >= kDawnSkirtStartHour && h < kDawnSunRiseHour)
		{
			outEl = parkEl
				+ (h - kDawnSkirtStartHour) * kSunTwilightElRateDegPerHour;
			outAz = kSunDayAz0
				- kSunAzRateDegPerHour * (kDawnEndHour - h);
			return;
		}
		// Dawn above horizon: el 0→golden until day core.
		if (h >= kDawnSunRiseHour && h < kDawnEndHour)
		{
			outEl = (h - kDawnSunRiseHour) * kSunTwilightElRateDegPerHour;
			outAz = kSunDayAz0
				- kSunAzRateDegPerHour * (kDawnEndHour - h);
			return;
		}
		// Day core [7, 20): el sine golden↔peak; az 115→245.
		if (h >= kSunDayCoreStartHour && h < kSunDayCoreEndHour)
		{
			const float coreSpan = kSunDayCoreEndHour - kSunDayCoreStartHour;
			float t = (h - kSunDayCoreStartHour) / coreSpan;
			t = std::clamp(t, 0.0f, 1.0f);
			outEl = kSunGoldenElDeg
				+ (kSunPeakElDeg - kSunGoldenElDeg) * std::sin(t * PI);
			outAz = kSunDayAz0 + t * (kSunDayAz1 - kSunDayAz0);
			return;
		}
		// Dusk to geometric set: el golden→0.
		if (h >= kDuskStartHour && h < kDuskSunSetHour)
		{
			outEl = kSunGoldenElDeg
				- (h - kDuskStartHour) * kSunTwilightElRateDegPerHour;
			outAz = kSunDayAz1
				+ kSunAzRateDegPerHour * (h - kDuskStartHour);
			return;
		}
		// Post-set sink below horizon until skirt (still drawn; no poof at el=0).
		if (h >= kDuskSunSetHour && h < kDuskSkirtEndHour)
		{
			outEl = 0.0f
				- (h - kDuskSunSetHour) * kSunTwilightElRateDegPerHour;
			outAz = kSunDayAz1
				+ kSunAzRateDegPerHour * (h - kDuskStartHour);
			return;
		}
		// Night: continuous under-horizon Hermite arc wrapping midnight (C1 at skirts).
		if (h >= kDuskSkirtEndHour || h < kDawnSkirtStartHour)
		{
			const float nightSpanHours =
				(24.0f - kDuskSkirtEndHour) + kDawnSkirtStartHour;
			float t = (h >= kDuskSkirtEndHour)
				? (h - kDuskSkirtEndHour) / nightSpanHours
				: ((h + 24.0f) - kDuskSkirtEndHour) / nightSpanHours;
			t = std::clamp(t, 0.0f, 1.0f);

			const float el0 = parkEl;
			const float el1 = parkEl;
			const float elM0 = -kSunTwilightElRateDegPerHour * nightSpanHours;
			const float elM1 = +kSunTwilightElRateDegPerHour * nightSpanHours;
			outEl = Hermite1D(t, el0, el1, elM0, elM1);

			const float az0 = parkAzDusk;
			const float az1 = parkAzDawn + 360.0f; // long arc west
			const float azM = kSunAzRateDegPerHour * nightSpanHours;
			outAz = NormalizeDeg360(Hermite1D(t, az0, az1, azM, azM));
			return;
		}
		// Fallback (should not hit): day lip.
		outEl = kSunGoldenElDeg;
		outAz = kSunDayAz0;
	}

	// Continuous 0..1 day amount — same windows as MainState / GetDayNightAmount.
	float SkyDayAmount()
	{
		return GetDayNightAmount();
	}

	bool SkyFluffUsesStormTint(WeatherType type)
	{
		return type == WeatherType::Rain
			|| type == WeatherType::Snow
			|| type == WeatherType::Overcast;
	}

	void DrawTexturedXZQuad(const Texture2D& tex, Vector3 center, float halfX, float halfZ, Color tint)
	{
		if (tex.id == 0)
		{
			return;
		}
		const float y = center.y;
		rlSetTexture(tex.id);
		rlBegin(RL_QUADS);
		rlColor4ub(tint.r, tint.g, tint.b, tint.a);
		rlNormal3f(0.0f, 1.0f, 0.0f);
		rlTexCoord2f(0.0f, 1.0f);
		rlVertex3f(center.x - halfX, y, center.z - halfZ);
		rlTexCoord2f(0.0f, 0.0f);
		rlVertex3f(center.x - halfX, y, center.z + halfZ);
		rlTexCoord2f(1.0f, 0.0f);
		rlVertex3f(center.x + halfX, y, center.z + halfZ);
		rlTexCoord2f(1.0f, 1.0f);
		rlVertex3f(center.x + halfX, y, center.z - halfZ);
		rlEnd();
		rlSetTexture(0);
	}
}

void WeatherSystem::Init()
{
	m_type = WeatherType::Clear;
	m_phase = WeatherPhase::Idle;
	m_intensity = WeatherIntensity::Medium;
	m_remainingMinutes = 0;
	m_hasEggOrigin = false;
	m_eggObjectId = -1;
	m_manualOverride = false;
	m_manualOrigin = { 0, 0, 0 };
	m_pending = {};
	m_music.musicRainTrack = 4;
	m_music.musicSnowTrack = 5;
	m_particles.assign(kMaxParticles, Particle{});
	m_edgeClouds.assign(kMaxEdgeClouds, EdgeCloud{});
	m_skyClouds.assign(kMaxSkyClouds, SkyCloud{});
	ClearParticles();
	ClearEdgeClouds();
	ClearSkyClouds();
	m_spawnAccumulator = 0;
	m_skySpawnAccumulator = 0;
	m_flashTimer = 0;
	m_flashCooldown = 0;
	m_weatherTickAccum = 0;
	m_fogFade = 0;
	m_fogIntensityScale = 1.0f;
	m_overcastFade = 0;
	m_fogWasActive = false;
	m_targetCount = 0;
	m_bursts = 0;
	m_delay = 0;
	m_direction = 0;
	// Wind starts Off; picker / storm seed / Lua turn it on.
	m_windDir = 0;
	m_windYawDeg = 0;
	m_windSpeed = WeatherWindSpeed::Off;
	m_stormFlag = 0;
	m_hasCamera = false;
	m_orreryState = 9;
	StopWeatherMusicIfPlaying();
	ConfigureEffectParams(WeatherType::Clear, WeatherIntensity::Medium);
	RefreshOrreryStateFromFlags();
}

void WeatherSystem::Shutdown()
{
	m_pending = {};
	ClearWeather(false);
}

void WeatherSystem::SetOrreryState(int state)
{
	m_orreryState = std::clamp(state, 0, 9);
}

void WeatherSystem::RefreshOrreryStateFromFlags()
{
	if (!g_ScriptingSystem)
	{
		m_orreryState = 9;
		return;
	}
	// Mirror utility_event_0481: count unset flags among the nine plot bits.
	static constexpr int kFlags[] = { 493, 308, 482, 599, 481, 3, 301, 4, 5 };
	int count = 0;
	for (int flag : kFlags)
	{
		if (!g_ScriptingSystem->GetFlag(flag))
		{
			++count;
		}
	}
	m_orreryState = std::clamp(count, 0, 9);
}

float WeatherSystem::GetMoonLightAmount() const
{
	float sunAz = 0.0f;
	float sunEl = 0.0f;
	SunAzElFromClock(GetSmoothClockHours(), sunAz, sunEl);
	const Vector3 sunDir = SkyDirFromAzEl(sunAz, sunEl);

	MoonState tram{};
	MoonState fel{};
	EvaluateMoons(sunDir, tram, fel);

	// I_phase × V_altitude (geometric el=0), preserve relative weights; not draw-cull −22°.
	float amount = tram.illumination * tram.altitudeVis * kTrammelLightWeight
		+ fel.illumination * fel.altitudeVis * kFeluccaLightWeight;
	amount *= (1.0f - std::clamp(m_overcastFade, 0.0f, 1.0f));
	const float dayAmount = SkyDayAmount();
	// Night contribution only (pale day moons don't light the ground).
	amount *= (1.0f - dayAmount);
	return std::clamp(amount, 0.0f, 1.0f);
}

bool WeatherSystem::TypeWantsOvercast(WeatherType type) const
{
	return type == WeatherType::Snow
		|| type == WeatherType::Rain
		|| type == WeatherType::Overcast;
}

bool WeatherSystem::IsFadingOut() const
{
	return m_phase == WeatherPhase::Stopping || m_phase == WeatherPhase::Finishing;
}

bool WeatherSystem::SpawnsPrecipParticles() const
{
	return m_type == WeatherType::Rain
		|| m_type == WeatherType::Snow
		|| m_type == WeatherType::Sparkle;
}

void WeatherSystem::UpdateGameMinute()
{
	if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle && !m_pending.active)
	{
		return;
	}

	if (m_remainingMinutes > 0 && !IsFadingOut())
	{
		--m_remainingMinutes;
		if (m_remainingMinutes <= 0)
		{
			// Do NOT wipe m_pending — picker/Lua may have queued an override.
			ClearWeather(true);
		}
	}
}

void WeatherSystem::SetWeather(int type, int durationMinutes, bool fromEgg,
	Vector3 eggOrigin, int eggObjectId, int intensity)
{
	auto takeManualOwnership = [this]() {
		m_manualOverride = true;
		m_hasEggOrigin = false;
		m_eggObjectId = -1;
		if (g_Player)
		{
			if (U7Object* avatar = g_Player->GetAvatarObject())
			{
				m_manualOrigin = avatar->m_Pos;
				return;
			}
		}
		m_manualOrigin = { 0, 0, 0 };
	};

	if (type == 255)
	{
		// Debug/Lua clear: own the clear so nearby weather eggs don't instantly re-hatch.
		takeManualOwnership();
		m_pending = {};
		ClearWeather(true);
		return;
	}

	if (type < 0 || type > 6)
	{
		Log("WeatherSystem::SetWeather: ignoring out-of-range type " + std::to_string(type));
		return;
	}

	WeatherIntensity inten = WeatherIntensity::Medium;
	if (intensity >= 0 && intensity <= 2)
	{
		inten = static_cast<WeatherIntensity>(intensity);
	}

	const WeatherType newType = static_cast<WeatherType>(type);

	if (fromEgg)
	{
		m_manualOverride = false;
	}
	else
	{
		takeManualOwnership();
	}

	// Sparkle snaps on/off (exclusive anti-magic field).
	if (newType == WeatherType::Sparkle || m_type == WeatherType::Sparkle)
	{
		m_pending = {};
		ApplyType(newType, durationMinutes, fromEgg, eggOrigin, eggObjectId, inten);
		return;
	}

	// Same type already running: rain/snow/fog retarget intensity; others keep as-is.
	if (m_type == newType && !IsFadingOut() && m_type != WeatherType::Clear)
	{
		m_remainingMinutes = (durationMinutes <= 0) ? 6000 : durationMinutes;
		if (fromEgg)
		{
			m_hasEggOrigin = true;
			m_eggOrigin = eggOrigin;
			m_eggObjectId = eggObjectId;
		}
		else
		{
			m_hasEggOrigin = false;
			m_eggObjectId = -1;
		}
		if (newType == WeatherType::Rain || newType == WeatherType::Snow || newType == WeatherType::Fog)
		{
			m_intensity = inten;
			ConfigureEffectParams(newType, inten);
			if (newType == WeatherType::Rain || newType == WeatherType::Snow)
			{
				if (m_phase == WeatherPhase::Steady)
				{
					m_targetCount = m_maxCount;
				}
				else if (m_targetCount > m_maxCount)
				{
					m_targetCount = m_maxCount;
				}
			}
		}
		return;
	}

	// Already idle/clear: start immediately (blend fades may still drain — OK to crossfade).
	if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle)
	{
		m_pending = {};
		ApplyType(newType, durationMinutes, fromEgg, eggOrigin, eggObjectId, inten);
		return;
	}

	// Queue B, fade out A first. Manual pending must not carry egg origin.
	m_pending.active = true;
	m_pending.type = newType;
	m_pending.intensity = inten;
	m_pending.durationMinutes = durationMinutes;
	m_pending.fromEgg = fromEgg;
	m_pending.eggOrigin = fromEgg ? eggOrigin : Vector3{ 0, 0, 0 };
	m_pending.eggObjectId = fromEgg ? eggObjectId : -1;

	if (!IsFadingOut())
	{
		ClearWeather(true);
	}
}

int WeatherSystem::ResolveMaxCount(WeatherType type, WeatherIntensity intensity) const
{
	switch (type)
	{
	case WeatherType::Snow:
	case WeatherType::Rain:
		switch (intensity)
		{
		case WeatherIntensity::Light:  return kLightParticles;
		case WeatherIntensity::Heavy:  return kHeavyParticles;
		case WeatherIntensity::Medium:
		default:                       return kTargetParticles;
		}
	case WeatherType::Sparkle:
		return kSparkleParticles;
	case WeatherType::Overcast:
	case WeatherType::Cloudy:
		return 0; // edges + palette only; no precip particles
	default:
		return 0;
	}
}

float WeatherSystem::ResolveFallSpeed(WeatherType type, WeatherIntensity intensity) const
{
	float base = 0.0f;
	if (type == WeatherType::Rain)
	{
		base = 220.0f;
	}
	else if (type == WeatherType::Snow)
	{
		base = 40.0f;
	}
	else
	{
		return 0.0f;
	}

	switch (intensity)
	{
	case WeatherIntensity::Light:  return base * 0.70f;
	case WeatherIntensity::Heavy:  return base * 1.55f;
	case WeatherIntensity::Medium:
	default:                       return base;
	}
}

int WeatherSystem::AvatarFacing8() const
{
	if (!g_Player)
	{
		return GetRandomValue(0, 7);
	}
	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
	{
		return GetRandomValue(0, 7);
	}
	float deg = avatar->m_Angle;
	while (deg < 0.0f) deg += 360.0f;
	while (deg >= 360.0f) deg -= 360.0f;
	return static_cast<int>((deg + 22.5f) / 45.0f) % 8;
}

float WeatherSystem::WindSpeedScale(WeatherWindSpeed speed) const
{
	switch (speed)
	{
	case WeatherWindSpeed::Off:    return 0.0f;
	case WeatherWindSpeed::Light:  return 0.55f;
	case WeatherWindSpeed::Heavy:  return 1.45f;
	case WeatherWindSpeed::Medium:
	default:                       return 1.0f;
	}
}

float WeatherSystem::FlagAnimSpeedScale() const
{
	// Ambient breeze: Off still flutters at Light rate. Does not affect precip.
	if (m_windSpeed == WeatherWindSpeed::Off)
	{
		return WindSpeedScale(WeatherWindSpeed::Light);
	}
	return WindSpeedScale(m_windSpeed);
}

float WeatherSystem::PrecipWindDriftPixels() const
{
	// Steeper than WindSpeedScale so Heavy reads as a clear lean vs Light/Med.
	switch (m_windSpeed)
	{
	case WeatherWindSpeed::Off:    return 0.0f;
	case WeatherWindSpeed::Light:  return kPrecipWindDriftMedium * 0.75f;
	case WeatherWindSpeed::Heavy:  return kPrecipWindDriftMedium * 2.25f;
	case WeatherWindSpeed::Medium:
	default:                       return kPrecipWindDriftMedium;
	}
}

float WeatherSystem::CloudWindWorldSpeed() const
{
	// Low-band / ground shadows: Off still drifts slowly (plan).
	if (m_windSpeed == WeatherWindSpeed::Off)
	{
		return kCloudWorldSpeed * 0.28f;
	}
	return kCloudWorldSpeed * WindSpeedScale(m_windSpeed);
}

float WeatherSystem::SkyCloudWindWorldSpeed() const
{
	// High-band: Off = stationary; otherwise faster than low band.
	if (m_windSpeed == WeatherWindSpeed::Off)
	{
		return 0.0f;
	}
	return CloudWindWorldSpeed() * kSkyCloudSpeedMul;
}

float WeatherSystem::WindUnitWX() const
{
	// 0° = N (-Z): wx = sin(yaw), wz = -cos(yaw) — matches kDirWX/WZ octants.
	return std::sin(m_windYawDeg * DEG2RAD);
}

float WeatherSystem::WindUnitWZ() const
{
	return -std::cos(m_windYawDeg * DEG2RAD);
}

void WeatherSystem::UpdateWindYaw(float dt)
{
	const float target = static_cast<float>((m_windDir % 8 + 8) % 8) * 45.0f;
	float delta = target - m_windYawDeg;
	while (delta > 180.0f)
	{
		delta -= 360.0f;
	}
	while (delta < -180.0f)
	{
		delta += 360.0f;
	}
	// ~100°/s — a 45° picker step eases in under half a second.
	constexpr float kTurnDegPerSec = 100.0f;
	const float step = kTurnDegPerSec * dt;
	if (std::fabs(delta) <= step)
	{
		m_windYawDeg = target;
	}
	else
	{
		m_windYawDeg += (delta > 0.0f) ? step : -step;
	}
	while (m_windYawDeg < 0.0f)
	{
		m_windYawDeg += 360.0f;
	}
	while (m_windYawDeg >= 360.0f)
	{
		m_windYawDeg -= 360.0f;
	}
}

bool WeatherSystem::WantsWindEffects() const
{
	return m_type == WeatherType::Rain
		|| m_type == WeatherType::Snow
		|| m_type == WeatherType::Overcast
		|| m_type == WeatherType::Cloudy;
}

void WeatherSystem::SeedWindFromAvatar(WeatherIntensity intensity)
{
	m_windDir = (AvatarFacing8() + 3 + GetRandomValue(0, 2)) % 8;
	m_direction = m_windDir;
	// Do NOT snap m_windYawDeg — UpdateWindYaw lerps so flags, precip drift,
	// and edge clouds (WindUnitWX/WZ) ease into the new storm direction.
	// Map precip L/M/H (0–2) → wind Light/Medium/Heavy (1–3); never leave Off in a storm.
	m_windSpeed = static_cast<WeatherWindSpeed>(static_cast<int>(intensity) + 1);
}

void WeatherSystem::SetWeatherWind(int dir, int speed)
{
	m_windDir = ((dir % 8) + 8) % 8;
	m_direction = m_windDir;
	// m_windYawDeg lerps toward the new target in UpdateWindYaw — no snap.
	if (speed >= 0 && speed <= 3)
	{
		m_windSpeed = static_cast<WeatherWindSpeed>(speed);
	}
	RetargetEdgeCloudVelocities();
	RetargetSkyCloudVelocities();
}

void WeatherSystem::RetargetEdgeCloudVelocities()
{
	// Rebuild speed magnitude only. Heading stays with UpdateEdgeClouds, which
	// re-aims along the lerped m_windYawDeg every frame (no direction snap).
	for (EdgeCloud& c : m_edgeClouds)
	{
		if (!c.active)
		{
			continue;
		}
		const float use = CloudWindWorldSpeed()
			+ static_cast<float>(GetRandomValue(0, 30)) / 10.0f;
		const float mag = std::sqrt(c.vx * c.vx + c.vz * c.vz);
		if (mag < 0.01f)
		{
			c.vx = WindUnitWX() * use;
			c.vz = WindUnitWZ() * use;
		}
		else
		{
			c.vx = (c.vx / mag) * use;
			c.vz = (c.vz / mag) * use;
		}
	}
}

void WeatherSystem::UpdateFlagCloth(float dt)
{
	(void)dt;
	// Ambient breeze: flags follow wind outdoors even in Clear when speed != Off.
	// Precip/shadows stay gated by WantsWindEffects() elsewhere.
	if (IsAvatarSheltered() || !IsWindActive())
	{
		return;
	}

	// Cloth glTF extends along local +X. DrawModelEx Y-rot maps +X → (cos θ, 0, -sin θ).
	// Wind travel is (sin φ, 0, -cos φ) with φ = m_windYawDeg, so θ = 90° − φ aligns
	// the fabric with the same direction clouds/precip use (WindUnitWX/WZ).
	float angle = 90.0f - m_windYawDeg;
	while (angle < 0.0f)
	{
		angle += 360.0f;
	}
	while (angle >= 360.0f)
	{
		angle -= 360.0f;
	}

	for (U7Object* obj : g_sortedVisibleObjects)
	{
		if (!obj || !obj->m_shapeData || !obj->m_Visible || obj->m_isContained)
		{
			continue;
		}
		const int shape = obj->m_shapeData->GetShape();
		// Flag cloth only — mast (713) stays put.
		if (shape != 222 && shape != 232 && shape != 248)
		{
			continue;
		}
		obj->m_Angle = angle;
	}
}

void WeatherSystem::ConfigureEffectParams(WeatherType type, WeatherIntensity intensity)
{
	m_maxCount = ResolveMaxCount(type, intensity);
	m_fallSpeed = ResolveFallSpeed(type, intensity);
	m_firstFrame = 0;
	m_frameCount = 0;
	m_useSplashes = false;
	m_firstSplashFrame = 0;
	m_splashFrames = 0;

	switch (type)
	{
	case WeatherType::Snow:
		m_firstFrame = 13;
		m_frameCount = 8;
		// No splash: frames 21–27 are sparkle art and read as a sudden shrink/shape change.
		m_useSplashes = false;
		break;
	case WeatherType::Rain:
		m_firstFrame = 3;
		m_frameCount = 4;
		if (intensity != WeatherIntensity::Light)
		{
			m_useSplashes = true;
			m_firstSplashFrame = 7;
			m_splashFrames = 1;
		}
		break;
	case WeatherType::Sparkle:
		m_fallSpeed = 0;
		m_firstFrame = 21;
		m_frameCount = 7;
		break;
	default:
		break;
	}
}

void WeatherSystem::ApplyType(WeatherType type, int durationMinutes, bool fromEgg,
	Vector3 eggOrigin, int eggObjectId, WeatherIntensity intensity)
{
	if (type == WeatherType::Clear)
	{
		ClearWeather(false);
		return;
	}

	m_type = type;
	m_intensity = intensity;

	int minutes = durationMinutes;
	if (minutes <= 0)
	{
		minutes = 6000;
	}
	m_remainingMinutes = minutes;

	m_hasEggOrigin = fromEgg;
	m_eggOrigin = fromEgg ? eggOrigin : Vector3{ 0, 0, 0 };
	m_eggObjectId = fromEgg ? eggObjectId : -1;
	if (fromEgg)
	{
		m_manualOverride = false;
	}

	ConfigureEffectParams(type, intensity);
	ClearParticles();
	// Keep living edge clouds only if continuing storm look; otherwise clear.
	if (type == WeatherType::Fog || type == WeatherType::Sparkle)
	{
		ClearEdgeClouds();
	}
	m_spawnAccumulator = 0;
	m_flashTimer = 0;
	m_flashCooldown = GetRandomValue(2, 8) / 10.0f;
	m_weatherTickAccum = 0;

	const bool isStorm = (type == WeatherType::Rain || type == WeatherType::Snow
		|| type == WeatherType::Overcast || type == WeatherType::Cloudy);
	m_stormFlag = isStorm ? 2 : 0;
	m_targetCount = SpawnsPrecipParticles() ? (isStorm ? 1 : m_maxCount) : 0;
	m_bursts = 0;
	m_delay = (m_stormFlag * 25) / 2;
	if (isStorm)
	{
		SeedWindFromAvatar(intensity);
	}
	m_phase = m_stormFlag ? WeatherPhase::Burst : WeatherPhase::Ramping;

	if (type == WeatherType::Fog)
	{
		m_phase = WeatherPhase::Steady;
		m_delay = 0;
		m_targetCount = 0;
		m_fogWasActive = true;
		// Kick so the veil/dim read immediately; rest eases in over kFogFadeSeconds.
		if (m_fogFade < 0.28f)
		{
			m_fogFade = 0.28f;
		}
	}
	else if (type == WeatherType::Sparkle)
	{
		m_phase = WeatherPhase::Steady;
		m_targetCount = m_maxCount;
		m_delay = 0;
	}

	// Overcast dim/veil: kick early so day darkening is felt right away (Rain/Snow/Overcast).
	if (TypeWantsOvercast(type) && m_overcastFade < 0.35f)
	{
		m_overcastFade = 0.35f;
	}

	SyncWeatherMusic();
}

void WeatherSystem::ClearWeather(bool gradual)
{
	if (!gradual || (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle))
	{
		FinishClear();
		return;
	}

	// Sparkle snaps off — particles never drain via storm ticks.
	if (m_type == WeatherType::Sparkle)
	{
		FinishClear();
		return;
	}

	if (m_type == WeatherType::Fog)
	{
		m_fogWasActive = true;
		m_phase = WeatherPhase::Stopping;
		m_remainingMinutes = 0;
		return;
	}

	// Rain/Snow/Overcast/Cloudy: stop new spawns, let precip finish falling (sped up),
	// and let edge clouds expire quickly — never snap-clear clouds.
	// Sky fluff shortens too; Clear ambient may respawn light fluff after FinishClear.
	m_delay = 0;
	m_targetCount = 0;
	ShortenEdgeCloudLives(kEdgeCloudFadeOutLife);
	ShortenSkyCloudLives(kEdgeCloudFadeOutLife);
	m_phase = WeatherPhase::Stopping;
	m_remainingMinutes = 0;
}

void WeatherSystem::TryStartPending()
{
	if (!m_pending.active)
	{
		return;
	}
	if (!VisualEffectsCleared())
	{
		return;
	}

	PendingWeather p = m_pending;
	m_pending = {};
	ApplyType(p.type, p.durationMinutes, p.fromEgg, p.eggOrigin, p.eggObjectId, p.intensity);
}

void WeatherSystem::FinishClear()
{
	StopWeatherMusicIfPlaying();
	m_type = WeatherType::Clear;
	m_phase = WeatherPhase::Idle;
	m_remainingMinutes = 0;
	m_hasEggOrigin = false;
	m_eggObjectId = -1;
	m_targetCount = 0;
	m_bursts = 0;
	m_delay = 0;
	m_stormFlag = 0;
	ConfigureEffectParams(WeatherType::Clear, WeatherIntensity::Medium);
	ClearParticles();
	ClearEdgeClouds();
	// Keep high-band sky fluff into Clear; ambient spawn maintains a light layer.
	m_flashTimer = 0;

	// Keep fog/overcast blends decaying via UpdateBlendFades; then start pending.
	TryStartPending();
}

void WeatherSystem::ClearParticles()
{
	for (Particle& p : m_particles)
	{
		p = Particle{};
	}
}

void WeatherSystem::ClearEdgeClouds()
{
	for (EdgeCloud& c : m_edgeClouds)
	{
		c = EdgeCloud{};
	}
}

void WeatherSystem::ClearSkyClouds()
{
	for (SkyCloud& c : m_skyClouds)
	{
		c = SkyCloud{};
	}
}

void WeatherSystem::ShortenEdgeCloudLives(float maxLifeSeconds)
{
	for (EdgeCloud& c : m_edgeClouds)
	{
		if (c.active && c.life > maxLifeSeconds)
		{
			c.life = maxLifeSeconds;
		}
	}
}

void WeatherSystem::ShortenSkyCloudLives(float maxLifeSeconds)
{
	for (SkyCloud& c : m_skyClouds)
	{
		if (c.active && c.life > maxLifeSeconds)
		{
			c.life = maxLifeSeconds;
		}
	}
}

void WeatherSystem::RetargetSkyCloudVelocities()
{
	const float use = SkyCloudWindWorldSpeed();
	for (SkyCloud& c : m_skyClouds)
	{
		if (!c.active)
		{
			continue;
		}
		if (use < 0.01f)
		{
			c.vx = 0.0f;
			c.vz = 0.0f;
			continue;
		}
		const float jitter = static_cast<float>(GetRandomValue(0, 20)) / 10.0f;
		c.vx = WindUnitWX() * (use + jitter);
		c.vz = WindUnitWZ() * (use + jitter);
	}
}

void WeatherSystem::CheckEggDistanceCancel(Vector3 avatarPos, float maxDistanceTiles)
{
	// Manual picker/Lua weather: drop override once avatar walks away so eggs can hatch again.
	if (m_manualOverride)
	{
		const float mdx = avatarPos.x - m_manualOrigin.x;
		const float mdz = avatarPos.z - m_manualOrigin.z;
		if (std::sqrt(mdx * mdx + mdz * mdz) > maxDistanceTiles)
		{
			m_manualOverride = false;
		}
		return; // never cancel weather for egg distance while manual owns it
	}

	if (!m_hasEggOrigin || m_type == WeatherType::Clear)
	{
		return;
	}

	const float dx = avatarPos.x - m_eggOrigin.x;
	const float dz = avatarPos.z - m_eggOrigin.z;
	const float dist = std::sqrt(dx * dx + dz * dz);
	if (dist > maxDistanceTiles)
	{
		// Preserve a non-egg pending override (e.g. picker queued during egg weather).
		if (m_pending.active && !m_pending.fromEgg)
		{
			if (!IsFadingOut())
			{
				ClearWeather(true);
			}
			return;
		}
		m_pending = {};
		ClearWeather(true);
	}
}

bool WeatherSystem::EffectsEnabled() const
{
	if (!g_Engine)
	{
		return true;
	}
	return g_Engine->m_EngineConfig.GetNumber("weather_effects") >= 0.5f;
}

bool WeatherSystem::IsAvatarSheltered() const
{
	if (g_dungeonViewActive)
	{
		return true;
	}
	if (!g_pathfindingSystem || !g_Player)
	{
		return false;
	}
	U7Object* avatar = g_Player->GetAvatarObject();
	if (!avatar)
	{
		return false;
	}
	const int ax = static_cast<int>(std::floor(avatar->m_Pos.x));
	const int az = static_cast<int>(std::floor(avatar->m_Pos.z));
	return g_pathfindingSystem->IsInteriorTile(ax, az);
}

bool WeatherSystem::WantsOvercastPalette() const
{
	return m_overcastFade > 0.01f;
}

bool WeatherSystem::WantsFogPalette() const
{
	return m_fogFade > 0.01f;
}

bool WeatherSystem::WantsCloudSprites() const
{
	return m_type == WeatherType::Overcast
		|| m_type == WeatherType::Cloudy
		|| m_type == WeatherType::Rain
		|| m_type == WeatherType::Snow
		|| CountActiveEdgeClouds() > 0;
}

bool WeatherSystem::WantsOpenSky() const
{
	// Sky backdrop (clear color + dome/panel + fluff). Still draw when the avatar
	// is under a building roof so FP views through doors/windows show outdoor sky.
	// Dungeons stay black (no exterior sky). Precip/edge/flash use IsAvatarSheltered.
	return EffectsEnabled() && !g_dungeonViewActive;
}

bool WeatherSystem::WantsSkyFluff() const
{
	if (!WantsOpenSky())
	{
		return false;
	}
	// Clear gets light high fluff (no ground shadows). Storm types denser.
	return m_type == WeatherType::Clear
		|| m_type == WeatherType::Overcast
		|| m_type == WeatherType::Cloudy
		|| m_type == WeatherType::Rain
		|| m_type == WeatherType::Snow
		|| m_type == WeatherType::Fog
		|| CountActiveSkyClouds() > 0;
}

bool WeatherSystem::ShouldDrawPrecipitation() const
{
	if (!EffectsEnabled() || IsAvatarSheltered())
	{
		return false;
	}
	return m_type == WeatherType::Rain || m_type == WeatherType::Snow
		|| ((m_type == WeatherType::Clear || IsFadingOut())
			&& CountActiveParticles() > 0 && m_fallSpeed > 0.0f);
}

int WeatherSystem::CountActiveParticles() const
{
	int n = 0;
	for (const Particle& p : m_particles)
	{
		if (p.active)
		{
			++n;
		}
	}
	return n;
}

int WeatherSystem::CountActiveEdgeClouds() const
{
	int n = 0;
	for (const EdgeCloud& c : m_edgeClouds)
	{
		if (c.active)
		{
			++n;
		}
	}
	return n;
}

int WeatherSystem::CountActiveSkyClouds() const
{
	int n = 0;
	for (const SkyCloud& c : m_skyClouds)
	{
		if (c.active)
		{
			++n;
		}
	}
	return n;
}

bool WeatherSystem::VisualEffectsCleared() const
{
	// Blend fades (fog/overcast) may still drain — pending weather is allowed to crossfade.
	// Sky fluff is allowed to persist into Clear and does not block pending handoff.
	return CountActiveParticles() == 0
		&& CountActiveEdgeClouds() == 0;
}

void WeatherSystem::TryAddParticle()
{
	if (m_type != WeatherType::Sparkle)
	{
		if (!SpawnsPrecipParticles() || m_fallSpeed <= 0.0f)
		{
			return;
		}
	}

	const int active = CountActiveParticles();
	if (active >= m_targetCount || active >= m_maxCount || m_maxCount <= 0)
	{
		return;
	}

	int freeIndex = -1;
	for (int i = 0; i < static_cast<int>(m_particles.size()); ++i)
	{
		if (!m_particles[i].active)
		{
			freeIndex = i;
			break;
		}
	}
	if (freeIndex < 0)
	{
		return;
	}

	Particle& p = m_particles[freeIndex];
	p.active = true;
	p.splash = 0;
	p.animTimer = 0;
	p.forward = (GetRandomValue(0, 1) == 1);

	if (m_type == WeatherType::Sparkle)
	{
		p.x = static_cast<float>(GetRandomValue(0, 620));
		p.y = static_cast<float>(GetRandomValue(0, 340));
		p.endY = p.y;
		p.frame = m_firstFrame + GetRandomValue(0, std::max(0, m_frameCount - 1));
	}
	else
	{
		p.x = static_cast<float>(GetRandomValue(-40, 680));
		p.y = static_cast<float>(GetRandomValue(-40, 20));
		p.endY = static_cast<float>(GetRandomValue(120, 380));
		p.frame = 0;
	}
}

void WeatherSystem::TrySpawnEdgeBurst(Camera camera)
{
	// Keep spawning while sheltered — outdoor weather continues; Draw hides it indoors.
	if (m_delay == 0 || !WantsCloudSprites())
	{
		return;
	}
	if (IsFadingOut())
	{
		return;
	}

	int chance = 75;
	if (m_phase == WeatherPhase::Burst)
	{
		chance = m_delay;
	}
	else if (m_phase == WeatherPhase::Stopping)
	{
		chance = 9999;
	}

	if (GetRandomValue(0, std::max(1, chance) - 1) != 0)
	{
		return;
	}

	const int count = GetRandomValue(1, 3);
	const auto& clouds = g_spriteTable[kCloudSpriteShape];
	if (clouds.empty())
	{
		++m_bursts;
		return;
	}

	const float speed = CloudWindWorldSpeed() + static_cast<float>(GetRandomValue(0, 30)) / 10.0f;
	const float wx = WindUnitWX();
	const float wz = WindUnitWZ();
	const float vx = wx * speed;
	const float vz = wz * speed;

	const Vector3 center = camera.target;
	const float spawnDist = 28.0f + static_cast<float>(GetRandomValue(0, 12));
	// Incoming side = opposite travel direction.
	const float inX = center.x - wx * spawnDist;
	const float inZ = center.z - wz * spawnDist;
	// Sit near ground — these are cloud *shadows* on the terrain, not sky billboards.
	const float baseY = 0.12f;

	for (int n = 0; n < count; ++n)
	{
		int slot = -1;
		for (int i = 0; i < static_cast<int>(m_edgeClouds.size()); ++i)
		{
			if (!m_edgeClouds[i].active)
			{
				slot = i;
				break;
			}
		}
		if (slot < 0)
		{
			break;
		}

		const float lateral = static_cast<float>(GetRandomValue(-14, 14));
		// Perpendicular in XZ: (-vz, vx) normalized-ish.
		float px = -vz;
		float pz = vx;
		const float plen = std::sqrt(px * px + pz * pz);
		if (plen > 0.01f)
		{
			px = px / plen * lateral;
			pz = pz / plen * lateral;
		}
		else
		{
			px = lateral;
			pz = 0;
		}

		EdgeCloud& c = m_edgeClouds[slot];
		c.active = true;
		c.frame = GetRandomValue(0, static_cast<int>(clouds.size()) - 1);
		c.vx = vx;
		c.vz = vz;
		c.life = 10.0f + static_cast<float>(GetRandomValue(0, 50)) / 10.0f;
		c.worldX = inX + px;
		c.worldZ = inZ + pz;
		c.worldY = baseY + static_cast<float>(GetRandomValue(0, 8)) / 100.0f;
	}

	++m_bursts;
}

void WeatherSystem::UpdateEdgeClouds(float dt, Camera camera)
{
	const Vector3 center = camera.target;
	const float wx = WindUnitWX();
	const float wz = WindUnitWZ();
	for (EdgeCloud& c : m_edgeClouds)
	{
		if (!c.active)
		{
			continue;
		}
		// Re-aim along continuous wind yaw; keep each cloud's speed magnitude.
		float mag = std::sqrt(c.vx * c.vx + c.vz * c.vz);
		if (mag < 0.1f)
		{
			mag = CloudWindWorldSpeed();
		}
		c.vx = wx * mag;
		c.vz = wz * mag;
		c.worldX += c.vx * dt;
		c.worldZ += c.vz * dt;
		c.life -= dt;
		const float dx = c.worldX - center.x;
		const float dz = c.worldZ - center.z;
		const float dist = std::sqrt(dx * dx + dz * dz);
		if (c.life <= 0.0f || dist > 80.0f)
		{
			c.active = false;
		}
	}
}

void WeatherSystem::TrySpawnSkyCloud(Camera camera, bool clearAmbient)
{
	if (!WantsSkyFluff() || IsFadingOut())
	{
		return;
	}
	if (clearAmbient && m_type != WeatherType::Clear)
	{
		return;
	}
	if (!clearAmbient && m_type == WeatherType::Clear)
	{
		return;
	}

	const auto& clouds = g_spriteTable[kCloudSpriteShape];
	if (clouds.empty())
	{
		return;
	}

	const int active = CountActiveSkyClouds();
	const int softCap = clearAmbient ? 4 : kMaxSkyClouds;
	if (active >= softCap)
	{
		return;
	}

	int slot = -1;
	for (int i = 0; i < static_cast<int>(m_skyClouds.size()); ++i)
	{
		if (!m_skyClouds[i].active)
		{
			slot = i;
			break;
		}
	}
	if (slot < 0)
	{
		return;
	}

	const float wx = WindUnitWX();
	const float wz = WindUnitWZ();
	const float speed = SkyCloudWindWorldSpeed()
		+ ((m_windSpeed == WeatherWindSpeed::Off)
			? 0.0f
			: static_cast<float>(GetRandomValue(0, 25)) / 10.0f);
	const Vector3 center = camera.target;
	const float spawnDist = 32.0f + static_cast<float>(GetRandomValue(0, 18));
	const float inX = center.x - wx * spawnDist;
	const float inZ = center.z - wz * spawnDist;
	const float lateral = static_cast<float>(GetRandomValue(-18, 18));
	float px = -wz;
	float pz = wx;
	const float plen = std::sqrt(px * px + pz * pz);
	if (plen > 0.01f)
	{
		px = px / plen * lateral;
		pz = pz / plen * lateral;
	}
	else
	{
		px = lateral;
		pz = 0.0f;
	}

	const float heightT = static_cast<float>(GetRandomValue(0, 100)) / 100.0f;
	SkyCloud& c = m_skyClouds[slot];
	c.active = true;
	c.frame = GetRandomValue(0, static_cast<int>(clouds.size()) - 1);
	c.vx = wx * speed;
	c.vz = wz * speed;
	c.life = clearAmbient
		? (18.0f + static_cast<float>(GetRandomValue(0, 80)) / 10.0f)
		: (12.0f + static_cast<float>(GetRandomValue(0, 60)) / 10.0f);
	c.maxLife = c.life;
	c.worldX = inX + px;
	c.worldZ = inZ + pz;
	c.worldY = kSkyCloudBaseY + heightT * kSkyCloudYSpan;
	c.size = 9.0f + static_cast<float>(GetRandomValue(0, 70)) / 10.0f;
	c.alpha = clearAmbient ? 0.35f : (0.50f + static_cast<float>(GetRandomValue(0, 25)) / 100.0f);
}

void WeatherSystem::UpdateSkyClouds(float dt, Camera camera)
{
	const Vector3 center = camera.target;
	const float wx = WindUnitWX();
	const float wz = WindUnitWZ();
	const float baseSpeed = SkyCloudWindWorldSpeed();
	for (SkyCloud& c : m_skyClouds)
	{
		if (!c.active)
		{
			continue;
		}
		if (baseSpeed < 0.01f)
		{
			c.vx = 0.0f;
			c.vz = 0.0f;
		}
		else
		{
			float mag = std::sqrt(c.vx * c.vx + c.vz * c.vz);
			if (mag < 0.1f)
			{
				mag = baseSpeed;
			}
			c.vx = wx * mag;
			c.vz = wz * mag;
		}
		c.worldX += c.vx * dt;
		c.worldZ += c.vz * dt;
		c.life -= dt;
		const float dx = c.worldX - center.x;
		const float dz = c.worldZ - center.z;
		const float dist = std::sqrt(dx * dx + dz * dz);
		if (c.life <= 0.0f || dist > 95.0f)
		{
			c.active = false;
		}
	}
}

void WeatherSystem::UpdateStormTick()
{
	if (m_type == WeatherType::Clear || m_type == WeatherType::Fog || m_type == WeatherType::Sparkle)
	{
		return;
	}

	switch (m_phase)
	{
	case WeatherPhase::Burst:
		if (!(m_bursts < 3 && m_delay != 0))
		{
			m_phase = WeatherPhase::Ramping;
		}
		break;
	case WeatherPhase::Ramping:
		if (m_targetCount >= m_maxCount)
		{
			m_phase = WeatherPhase::Steady;
		}
		else if (SpawnsPrecipParticles())
		{
			++m_targetCount;
		}
		else
		{
			m_phase = WeatherPhase::Steady;
		}
		break;
	case WeatherPhase::Steady:
		break;
	case WeatherPhase::Stopping:
		m_delay = 0;
		// Drain targetCount quickly so we don't linger in Stopping for Heavy storms.
		if (m_targetCount <= 0)
		{
			m_phase = WeatherPhase::Finishing;
		}
		else
		{
			m_targetCount = std::max(0, m_targetCount - 20);
		}
		break;
	case WeatherPhase::Finishing:
		if (CountActiveParticles() <= 0 && CountActiveEdgeClouds() <= 0)
		{
			FinishClear();
			return;
		}
		break;
	default:
		break;
	}

	if (SpawnsPrecipParticles()
		&& (m_phase == WeatherPhase::Burst || m_phase == WeatherPhase::Ramping
			|| m_phase == WeatherPhase::Steady))
	{
		int newParticles = GetRandomValue(1, 12);
		while (newParticles > 0 && CountActiveParticles() < m_targetCount)
		{
			TryAddParticle();
			--newParticles;
		}
	}

	if (m_delay != 0 && m_hasCamera && WantsCloudSprites() && !IsFadingOut())
	{
		TrySpawnEdgeBurst(m_lastCamera);
	}

	// Storm sky fluff — denser than Clear ambient (spawned from Update).
	if (m_hasCamera && WantsSkyFluff() && !IsFadingOut() && m_type != WeatherType::Clear)
	{
		if (GetRandomValue(0, 4) == 0)
		{
			TrySpawnSkyCloud(m_lastCamera, false);
		}
	}
}

void WeatherSystem::UpdateParticles(float dt)
{
	constexpr float kSparkleFrameSeconds = 0.08f;
	const int sparkleLast = m_firstFrame + m_frameCount - 1;

	for (Particle& p : m_particles)
	{
		if (!p.active)
		{
			continue;
		}

		// Safety: non-sparkle zero-speed orphans (Overcast leftover).
		if (m_type != WeatherType::Sparkle && m_fallSpeed <= 0.0f && p.splash <= 0.0f)
		{
			p.active = false;
			continue;
		}

		if (p.splash > 0)
		{
			p.splash -= dt * 12.0f;
			if (p.splash <= 0)
			{
				p.active = false;
			}
			continue;
		}

		if (m_type == WeatherType::Sparkle && m_fallSpeed <= 0.0f)
		{
			p.animTimer += dt;
			while (p.animTimer >= kSparkleFrameSeconds)
			{
				p.animTimer -= kSparkleFrameSeconds;
				if (p.forward)
				{
					++p.frame;
					if (p.frame >= sparkleLast)
					{
						p.frame = sparkleLast;
						p.forward = false;
						p.x = static_cast<float>(GetRandomValue(0, 620));
						p.y = static_cast<float>(GetRandomValue(0, 340));
						p.frame = m_firstFrame + GetRandomValue(0, std::max(0, m_frameCount - 1));
						p.forward = (GetRandomValue(0, 1) == 1);
					}
				}
				else
				{
					--p.frame;
					if (p.frame <= m_firstFrame)
					{
						p.frame = m_firstFrame;
						p.forward = true;
					}
				}
			}
			continue;
		}

		const float fallMul = IsFadingOut() ? kPrecipFadeOutFallMul : 1.0f;
		p.y += m_fallSpeed * fallMul * dt;
		// Screen-space wind drift: project world wind through the camera so streaks
		// travel the same way edge-cloud shadows move on screen (and match flags).
		if (WantsWindEffects() && m_fallSpeed > 0.0f)
		{
			const float drift = PrecipWindDriftPixels() * dt;
			float dx = 0.0f;
			float dy = 0.0f;
			if (m_hasCamera)
			{
				const Vector3 origin = m_lastCamera.target;
				const Vector3 tip = {
					origin.x + WindUnitWX(),
					origin.y,
					origin.z + WindUnitWZ()
				};
				const Vector2 s0 = GetWorldToScreen(origin, m_lastCamera);
				const Vector2 s1 = GetWorldToScreen(tip, m_lastCamera);
				dx = s1.x - s0.x;
				dy = s1.y - s0.y;
				extern float g_DrawScale;
				if (g_DrawScale > 0.0f)
				{
					dx /= g_DrawScale;
					dy /= g_DrawScale;
				}
				const float len = std::sqrt(dx * dx + dy * dy);
				if (len > 0.01f)
				{
					dx /= len;
					dy /= len;
				}
				else
				{
					dx = 1.0f;
					dy = 0.0f;
				}
			}
			else
			{
				// No camera yet — crude fallback (same basis as before).
				dx = -(WindUnitWX() * 0.75f - WindUnitWZ() * 0.35f);
				dy = 0.0f;
			}
			p.x += dx * drift;
			p.y += dy * drift;
			if (p.x < -40.0f)
			{
				p.x += 700.0f;
			}
			else if (p.x > 660.0f)
			{
				p.x -= 700.0f;
			}
		}
		if (m_frameCount > 0)
		{
			p.frame = (p.frame + 1) % m_frameCount;
		}

		if (p.y >= p.endY)
		{
			// Skip splash during fade-out so precip clears faster for pending weather.
			if (m_useSplashes && m_splashFrames > 0 && !IsFadingOut())
			{
				p.splash = static_cast<float>(m_splashFrames);
			}
			else
			{
				p.active = false;
			}
		}
	}
}

void WeatherSystem::UpdateBlendFades(float dt)
{
	const bool fogOn = (m_type == WeatherType::Fog && !IsFadingOut());
	const float fogTarget = fogOn ? 1.0f : 0.0f;
	if (fogOn)
	{
		m_fogWasActive = true;
	}
	const float fogStep = dt / kFogFadeSeconds;
	if (m_fogFade < fogTarget)
	{
		m_fogFade = std::min(fogTarget, m_fogFade + fogStep);
	}
	else if (m_fogFade > fogTarget)
	{
		m_fogFade = std::max(fogTarget, m_fogFade - fogStep);
	}
	if (m_fogFade < 0.01f)
	{
		m_fogFade = 0;
		if (!fogOn)
		{
			m_fogWasActive = false;
		}
	}

	// Smooth Light/Medium/Heavy fog density (veil + dim) — no instant snaps.
	{
		const float intenTarget = (fogOn || m_fogFade > 0.01f)
			? FogIntensityScale(m_intensity)
			: 1.0f;
		const float intenStep = dt / kFogIntensityBlendSeconds;
		if (m_fogIntensityScale < intenTarget)
		{
			m_fogIntensityScale = std::min(intenTarget, m_fogIntensityScale + intenStep);
		}
		else if (m_fogIntensityScale > intenTarget)
		{
			m_fogIntensityScale = std::max(intenTarget, m_fogIntensityScale - intenStep);
		}
	}

	const bool overOn = TypeWantsOvercast(m_type) && !IsFadingOut() && m_type != WeatherType::Clear;
	const float overTarget = overOn ? 1.0f : 0.0f;
	const float overStep = dt / kOvercastFadeSeconds;
	if (m_overcastFade < overTarget)
	{
		m_overcastFade = std::min(overTarget, m_overcastFade + overStep);
	}
	else if (m_overcastFade > overTarget)
	{
		m_overcastFade = std::max(overTarget, m_overcastFade - overStep);
	}
	if (m_overcastFade < 0.01f)
	{
		m_overcastFade = 0;
	}

	// Fog-only stop: finish when veil drained.
	if (m_type == WeatherType::Fog && IsFadingOut() && m_fogFade < 0.02f)
	{
		FinishClear();
	}
	else if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle && m_pending.active)
	{
		TryStartPending();
	}
}

void WeatherSystem::Update(float dt)
{
	UpdateWindYaw(dt);
	UpdateBlendFades(dt);
	UpdateFlagCloth(dt);

	if (!EffectsEnabled())
	{
		return;
	}

	if (m_hasCamera)
	{
		UpdateEdgeClouds(dt, m_lastCamera);
		UpdateSkyClouds(dt, m_lastCamera);

		// Clear / Fog ambient high fluff (no ground shadows for Clear).
		if (WantsSkyFluff() && !IsFadingOut()
			&& (m_type == WeatherType::Clear || m_type == WeatherType::Fog)
			&& (m_phase == WeatherPhase::Idle || m_phase == WeatherPhase::Steady
				|| m_phase == WeatherPhase::Ramping || m_phase == WeatherPhase::Burst))
		{
			m_skySpawnAccumulator += dt;
			const float interval = (m_type == WeatherType::Fog) ? 1.4f : 2.2f;
			if (m_skySpawnAccumulator >= interval)
			{
				m_skySpawnAccumulator = 0.0f;
				if (GetRandomValue(0, 2) == 0)
				{
					TrySpawnSkyCloud(m_lastCamera, m_type == WeatherType::Clear);
				}
			}
		}
	}

	if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle)
	{
		return;
	}

	if (m_type == WeatherType::Sparkle)
	{
		if (IsFadingOut())
		{
			FinishClear();
			return;
		}
		if (m_phase == WeatherPhase::Steady)
		{
			m_spawnAccumulator += dt * static_cast<float>(m_maxCount) * 0.35f;
			while (m_spawnAccumulator >= 1.0f)
			{
				m_spawnAccumulator -= 1.0f;
				m_targetCount = m_maxCount;
				TryAddParticle();
			}
		}
		UpdateParticles(dt);
		return;
	}

	if (m_type == WeatherType::Fog)
	{
		return;
	}

	m_weatherTickAccum += dt;
	while (m_weatherTickAccum >= kWeatherTickSeconds)
	{
		m_weatherTickAccum -= kWeatherTickSeconds;
		UpdateStormTick();
		if (m_type == WeatherType::Clear && m_phase == WeatherPhase::Idle)
		{
			break;
		}
	}

	UpdateParticles(dt);

	// Exult Lightning_effect: flash+SFX 62 when not in dungeon (no day/night gate).
	// U7R: suppress in dungeon only; night storms may thunder.
	if (m_type == WeatherType::Rain && !g_dungeonViewActive && !IsFadingOut())
	{
		if (m_flashTimer > 0)
		{
			m_flashTimer -= dt;
		}
		else
		{
			m_flashCooldown -= dt;
			if (m_flashCooldown <= 0)
			{
				if (GetRandomValue(0, 100) < 8)
				{
					m_flashTimer = kFlashDuration;
					if (g_SoundSystem)
					{
						g_SoundSystem->PlaySound(BuildU7SfxPath(62));
					}
				}
				m_flashCooldown = GetRandomValue(15, 45) / 10.0f;
			}
		}
	}
	else if (m_type != WeatherType::Rain || g_dungeonViewActive)
	{
		m_flashTimer = 0;
	}
}

void WeatherSystem::ApplyLightingModifiers(Color& dayNightColor, bool isDay) const
{
	if (!EffectsEnabled() || IsAvatarSheltered())
	{
		return;
	}

	// Overcast dim is a daytime sky look; fog applies day or night so Fog picker is visible.
	// Rain/Snow intensity (and Overcast/Cloudy via current m_intensity) scales how dark it gets.
	if (isDay && m_overcastFade > 0.01f)
	{
		const float t = m_overcastFade;
		const float floor = OvercastDimMultiplier(m_intensity);
		const float dim = 1.0f - (1.0f - floor) * t;
		dayNightColor.r = static_cast<unsigned char>(dayNightColor.r * dim);
		dayNightColor.g = static_cast<unsigned char>(dayNightColor.g * dim);
		dayNightColor.b = static_cast<unsigned char>(dayNightColor.b * dim);
	}

	if (m_fogFade > 0.01f)
	{
		const float t = m_fogFade * m_fogIntensityScale;
		const float dimR = 1.0f - (1.0f - kFogDimR) * std::min(1.0f, t);
		const float dimG = 1.0f - (1.0f - kFogDimG) * std::min(1.0f, t);
		const float dimB = 1.0f - (1.0f - kFogDimB) * std::min(1.0f, t);
		dayNightColor.r = static_cast<unsigned char>(dayNightColor.r * dimR);
		dayNightColor.g = static_cast<unsigned char>(dayNightColor.g * dimG);
		dayNightColor.b = static_cast<unsigned char>(dayNightColor.b * dimB);
	}

	// Flash may fire at night too (Exult); still skip when sheltered so indoor view stays calm.
	if (m_flashTimer > 0)
	{
		dayNightColor = { 255, 255, 255, 255 };
	}
}

void WeatherSystem::GetSkyGradientColors(Color& zenith, Color& mid, Color& horizon) const
{
	// Base sky stops — day blue vs night indigo. Lerp by continuous dayAmount so
	// dusk/dawn windows match MainState via GetDayNightAmount (no g_isDay snap).
	// Do NOT multiply stops by g_dayNightColor RGB: that already includes
	// ApplyLightingModifiers (overcast/fog) and would double-dim.
	const Color dayZenith = { 70, 125, 205, 255 };
	const Color dayMid = { 130, 175, 220, 255 };
	const Color dayHorizon = { 175, 200, 225, 255 };
	const Color nightZenith = { 6, 8, 22, 255 };
	const Color nightMid = { 14, 18, 40, 255 };
	const Color nightHorizon = { 24, 28, 50, 255 };

	const float dayAmount = SkyDayAmount();
	zenith = LerpSkyColor(nightZenith, dayZenith, dayAmount);
	mid = LerpSkyColor(nightMid, dayMid, dayAmount);
	horizon = LerpSkyColor(nightHorizon, dayHorizon, dayAmount);

	// Overcast darkening scaled by dayAmount (fades out at night) — not gated on g_isDay.
	if (m_overcastFade > 0.01f && dayAmount > 0.01f)
	{
		const float floor = OvercastDimMultiplier(m_intensity);
		const float dim = 1.0f - (1.0f - floor) * m_overcastFade * dayAmount;
		zenith = ScaleSkyColor(zenith, dim * 0.92f);
		mid = ScaleSkyColor(mid, dim);
		horizon = ScaleSkyColor(horizon, dim * 1.02f);
	}

	// FP is inside fog — pull sky toward the veil tone.
	if (m_fogFade > 0.01f)
	{
		const float t = std::min(1.0f, m_fogFade * m_fogIntensityScale);
		const Color fogCol = { 220, 225, 230, 255 };
		zenith = LerpSkyColor(zenith, fogCol, t * 0.85f);
		mid = LerpSkyColor(mid, fogCol, t * 0.90f);
		horizon = LerpSkyColor(horizon, fogCol, t * 0.95f);
	}

	if (m_flashTimer > 0)
	{
		zenith = { 255, 255, 255, 255 };
		mid = { 255, 255, 255, 255 };
		horizon = { 240, 245, 255, 255 };
	}
}

Color WeatherSystem::GetSkyClearColor() const
{
	if (!WantsOpenSky())
	{
		return Color{ 0, 0, 0, 255 };
	}
	Color zenith{}, mid{}, horizon{};
	GetSkyGradientColors(zenith, mid, horizon);
	return horizon;
}

WeatherSystem::SkyAtmosphereState WeatherSystem::BuildSkyAtmosphereState() const
{
	SkyAtmosphereState atm{};
	atm.dayAmount = SkyDayAmount();
	SunAzElFromClock(GetSmoothClockHours(), atm.sunAz, atm.sunEl);
	atm.sunDir = SkyDirFromAzEl(atm.sunAz, atm.sunEl);
	GetSkyGradientColors(atm.zenith, atm.mid, atm.horizon);
	atm.warmTint = Color{ 255, 145, 70, 255 };
	atm.overcastFade = std::clamp(m_overcastFade, 0.0f, 1.0f);
	return atm;
}

Color WeatherSystem::EvaluateSkyColor(Vector3 skyDirection, const SkyAtmosphereState& atm)
{
	const Vector3 dir = Vector3Normalize(skyDirection);
	const float viewEl = ElevationDegFromDir(dir);
	const float viewAz = AzimuthDegFromDir(dir);

	const Color base = SkyGradientColorAtElevationDeg(
		atm.zenith, atm.mid, atm.horizon, viewEl);

	const float wSolar = WarmSolarWeight(atm.sunEl);
	const float wHorizon = WarmHorizonWeight(viewEl);
	const float dAz = ShortestAzDeltaDeg(viewAz, atm.sunAz);
	const float cosLobe = std::max(0.0f, std::cos(DegToRad(dAz)));
	const float wDirection = cosLobe * cosLobe; // soft forward lobe
	const float wOvercast = 1.0f - 0.85f * atm.overcastFade;
	const float w = std::clamp(wSolar * wHorizon * wDirection * wOvercast, 0.0f, 1.0f);

	return LerpSkyColor(base, atm.warmTint, w);
}

void WeatherSystem::DrawSkyGradient(Camera camera) const
{
	Color zenith{}, mid{}, horizon{};
	GetSkyGradientColors(zenith, mid, horizon);

	// Camera-facing panel — used by Title / DrawGameWorldFrame (menu-safe).
	Vector3 forward = Vector3Subtract(camera.target, camera.position);
	if (Vector3LengthSqr(forward) < 0.0001f)
	{
		forward = { 0.0f, 0.0f, -1.0f };
	}
	else
	{
		forward = Vector3Normalize(forward);
	}

	Vector3 right = Vector3CrossProduct(forward, camera.up);
	if (Vector3LengthSqr(right) < 0.0001f)
	{
		right = Vector3CrossProduct(forward, Vector3{ 0.0f, 0.0f, 1.0f });
	}
	if (Vector3LengthSqr(right) < 0.0001f)
	{
		right = { 1.0f, 0.0f, 0.0f };
	}
	else
	{
		right = Vector3Normalize(right);
	}
	Vector3 up = Vector3Normalize(Vector3CrossProduct(right, forward));

	constexpr float kDist = 70.0f;
	constexpr float kHalfW = 110.0f;
	constexpr float kHalfH = 90.0f;
	const Vector3 center = Vector3Add(camera.position, Vector3Scale(forward, kDist));

	auto corner = [&](float u, float v) {
		return Vector3Add(center,
			Vector3Add(Vector3Scale(right, u * kHalfW), Vector3Scale(up, v * kHalfH)));
	};

	const Vector3 topL = corner(-1.0f, 1.0f);
	const Vector3 topR = corner(1.0f, 1.0f);
	const Vector3 midL = corner(-1.0f, 0.15f);
	const Vector3 midR = corner(1.0f, 0.15f);
	const Vector3 botL = corner(-1.0f, -1.0f);
	const Vector3 botR = corner(1.0f, -1.0f);

	rlDisableDepthTest();
	rlDisableDepthMask();
	rlBegin(RL_TRIANGLES);

	auto tri = [](Vector3 a, Color ca, Vector3 b, Color cb, Vector3 c, Color cc) {
		rlColor4ub(ca.r, ca.g, ca.b, 255);
		rlVertex3f(a.x, a.y, a.z);
		rlColor4ub(cb.r, cb.g, cb.b, 255);
		rlVertex3f(b.x, b.y, b.z);
		rlColor4ub(cc.r, cc.g, cc.b, 255);
		rlVertex3f(c.x, c.y, c.z);
	};

	tri(topL, zenith, topR, zenith, midR, mid);
	tri(topL, zenith, midR, mid, midL, mid);
	tri(midL, mid, midR, mid, botR, horizon);
	tri(midL, mid, botR, horizon, botL, horizon);

	rlEnd();
	rlColor4ub(255, 255, 255, 255);
	rlEnableDepthMask();
	rlEnableDepthTest();
}

void WeatherSystem::DrawSkyHemisphere(Camera camera, const SkyAtmosphereState& atm) const
{
	// Camera-centered dome with a skirt below the camera-horizontal equator so the
	// sky fills down to the terrain skyline (down-tilted U7R camera). MainState only.
	constexpr float kRadius = 120.0f;
	constexpr int kSlices = 24;
	constexpr int kStacks = 32;
	const float skirtRad = DegToRad(kSkySkirtDeg);
	const float latMin = -skirtRad;
	const float latMax = PI * 0.5f;
	const float latSpan = latMax - latMin;

	const Vector3 origin = camera.position;

	auto domePoint = [&](int slice, int stack) -> Vector3 {
		const float t = static_cast<float>(stack) / static_cast<float>(kStacks);
		const float lat = latMin + t * latSpan;
		const float lon = (static_cast<float>(slice) / static_cast<float>(kSlices)) * (2.0f * PI);
		const float cosLat = std::cos(lat);
		const float sinLat = std::sin(lat);
		return Vector3{
			origin.x + kRadius * cosLat * std::sin(lon),
			origin.y + kRadius * sinLat,
			origin.z + kRadius * cosLat * std::cos(lon)
		};
	};

	auto colorAtPoint = [&](const Vector3& worldPos) -> Color {
		return EvaluateSkyColor(Vector3Subtract(worldPos, origin), atm);
	};

	// Engine boot (Main.cpp) leaves backface culling OFF for the whole game.
	// Never rlEnableBackfaceCulling here — that made MainState 3D go black.
	rlDisableDepthTest();
	rlDisableDepthMask();
	rlDisableBackfaceCulling(); // idempotent with boot; do not re-enable after

	rlBegin(RL_TRIANGLES);
	for (int stack = 0; stack < kStacks; ++stack)
	{
		for (int slice = 0; slice < kSlices; ++slice)
		{
			const int sliceNext = (slice + 1) % kSlices;
			const Vector3 p00 = domePoint(slice, stack);
			const Vector3 p10 = domePoint(sliceNext, stack);
			const Vector3 p01 = domePoint(slice, stack + 1);
			const Vector3 p11 = domePoint(sliceNext, stack + 1);
			const Color c00 = colorAtPoint(p00);
			const Color c10 = colorAtPoint(p10);
			const Color c01 = colorAtPoint(p01);
			const Color c11 = colorAtPoint(p11);

			rlColor4ub(c00.r, c00.g, c00.b, 255);
			rlVertex3f(p00.x, p00.y, p00.z);
			rlColor4ub(c10.r, c10.g, c10.b, 255);
			rlVertex3f(p10.x, p10.y, p10.z);
			rlColor4ub(c11.r, c11.g, c11.b, 255);
			rlVertex3f(p11.x, p11.y, p11.z);

			rlColor4ub(c00.r, c00.g, c00.b, 255);
			rlVertex3f(p00.x, p00.y, p00.z);
			rlColor4ub(c11.r, c11.g, c11.b, 255);
			rlVertex3f(p11.x, p11.y, p11.z);
			rlColor4ub(c01.r, c01.g, c01.b, 255);
			rlVertex3f(p01.x, p01.y, p01.z);
		}
	}
	rlEnd();

	rlColor4ub(255, 255, 255, 255);
	rlDrawRenderBatchActive();
	rlEnableDepthMask();
	rlEnableDepthTest();
}

void WeatherSystem::DrawCelestialBodies(Camera camera, const SkyAtmosphereState& atm) const
{
	const float dayAmount = atm.dayAmount;
	const float overcastDim = 1.0f - 0.85f * std::clamp(atm.overcastFade, 0.0f, 1.0f);
	if (overcastDim < 0.08f)
	{
		return;
	}

	const float sidereal = SiderealYawDeg();
	const float skyLum = SkyLuminance(dayAmount);
	const float timeSec = static_cast<float>(GetTime());
	// Path/amber use world el=0; draw cull at sky-dome skirt (iso terrain join).
	const float drawCullEl = -kSkySkirtDeg;

	const float sunAz = atm.sunAz;
	const float sunEl = atm.sunEl;
	const Vector3 sunDir = atm.sunDir;

	rlDisableDepthTest();
	rlDisableDepthMask();
	rlDisableBackfaceCulling();

	auto drawIfAboveHorizon = [&](Vector3 dirAlreadyRotated, float radius, Color color, int segs) {
		const float el = ElevationDegFromDir(dirAlreadyRotated);
		if (el < drawCullEl)
		{
			return;
		}
		DrawCelestialDisc(camera, SkyWorldPosFromDir(camera, dirAlreadyRotated), radius, color, segs);
	};

	// --- Stars: full-sphere scatter, spectral types, flicker, sky-contrast washout ---
	{
		bool anyStar = false;
		for (int i = 0; i < kStarCount; ++i)
		{
			const float ra = Hash01(i, 11) * 360.0f;
			const float u = Hash01(i, 29);
			const float dec = RadToDeg(std::asin(std::clamp(2.0f * u - 1.0f, -1.0f, 1.0f)));
			const Vector3 dir = RotateCelestial(EquatorialDir(ra, dec), sidereal);
			if (ElevationDegFromDir(dir) < drawCullEl)
			{
				continue;
			}

			// Spectral type 0..3: blue-white / white / yellow / orange
			const float typeRoll = Hash01(i, 47);
			Color tint{ 230, 235, 255, 255 };
			float mag = 0.55f; // intrinsic luminance
			float size = 0.16f;
			if (typeRoll < 0.22f)
			{
				tint = Color{ 180, 205, 255, 255 };
				mag = 0.70f;
				size = 0.20f;
			}
			else if (typeRoll < 0.55f)
			{
				tint = Color{ 235, 238, 255, 255 };
				mag = 0.58f;
				size = 0.17f;
			}
			else if (typeRoll < 0.82f)
			{
				tint = Color{ 255, 236, 190, 255 };
				mag = 0.48f;
				size = 0.15f;
			}
			else
			{
				tint = Color{ 255, 190, 140, 255 };
				mag = 0.40f;
				size = 0.14f;
			}
			mag *= 0.75f + 0.45f * Hash01(i, 61);
			size *= 0.85f + 0.40f * Hash01(i, 67);

			const float omega = 1.2f + 6.5f * Hash01(i, 71);
			const float phase = Hash01(i, 73) * (2.0f * PI);
			const float steady = Hash01(i, 79);
			const float flickerAmt = 0.04f + 0.16f * (1.0f - steady); // some nearly steady
			const float flicker = 1.0f - flickerAmt
				+ flickerAmt * (0.5f + 0.5f * std::sin(timeSec * omega + phase));

			const float vis = BodyContrastVis(mag * flicker, skyLum) * overcastDim;
			if (vis < 0.02f)
			{
				continue;
			}
			anyStar = true;
			tint.a = static_cast<unsigned char>(std::clamp(static_cast<int>(255.0f * vis), 0, 255));
			DrawCelestialDisc(camera, SkyWorldPosFromDir(camera, dir), size, tint, 6);
		}
		(void)anyStar;
	}

	// --- Planets: orrery RA/Dec + higher intrinsic lum (twilight-visible) ---
	{
		const int state = std::clamp(m_orreryState, 0, 9);
		for (int frame = 0; frame < 8; ++frame)
		{
			const float dx = static_cast<float>(kOrreryOffsets[state][frame][0]);
			const float dy = static_cast<float>(kOrreryOffsets[state][frame][1]);
			const float ra = std::atan2(dx, -dy) * (180.0f / PI) + static_cast<float>(frame) * 3.0f;
			const float dec = -8.0f + static_cast<float>(frame) * 2.2f
				+ 2.0f * std::sin(DegToRad(ra * 1.3f + frame * 25.0f));
			const Vector3 dir = RotateCelestial(EquatorialDir(ra, dec), sidereal);
			const float intrinsic = 0.78f + 0.08f * static_cast<float>(frame % 3);
			const float vis = BodyContrastVis(intrinsic, skyLum) * overcastDim;
			if (vis < 0.02f)
			{
				continue;
			}
			Color col = kPlanetColors[frame];
			col.a = static_cast<unsigned char>(std::clamp(static_cast<int>(255.0f * vis), 0, 255));
			drawIfAboveHorizon(dir, kPlanetRadius + static_cast<float>(frame) * 0.012f, col, 8);
		}
	}

	// --- Moons: Modelo A (calendar phase) + geometric place vs sun; shared MoonState ---
	{
		const float moonNight = 1.0f - dayAmount;
		const float moonDayPale = 0.28f * dayAmount;
		const float moonVis = std::clamp((moonNight + moonDayPale) * overcastDim, 0.0f, 1.0f);
		if (moonVis > 0.02f)
		{
			MoonState tram{};
			MoonState fel{};
			EvaluateMoons(sunDir, tram, fel);

			auto drawMoon = [&](const MoonState& moon) {
				if (moon.elevationDeg < drawCullEl)
				{
					return;
				}
				const Vector3 worldPos = SkyWorldPosFromDir(camera, moon.dir);
				const float aMul = moonVis * (0.70f + 0.30f * moon.illumination);
				Color dayHigh{ 215, 230, 255, 255 };
				Color nightHigh{ 255, 250, 235, 255 };
				Color amberLit{ 255, 175, 110, 255 };
				Color noonLit = LerpColorRGB(nightHigh, dayHigh, dayAmount);
				Color lit = HorizonWarmLit(
					noonLit, amberLit, moon.elevationDeg - kWorldHorizonDeg, kMoonWarmthElDeg);
				lit.a = static_cast<unsigned char>(std::clamp(static_cast<int>(255.0f * aMul), 0, 255));

				// Opaque silhouette always (phase ≠ full): night black → sky-matched by day.
				// Alpha stays 255 so stars stay occulted; fade is RGB contrast only.
				Color softShade{ 0, 0, 0, 0 };
				const float darkFrac = 1.0f - moon.illumination;
				const float phaseWantsShade = Smoothstep(0.08f, 0.95f, darkFrac);
				if (phaseWantsShade > 0.01f)
				{
					const Color localSky = EvaluateSkyColor(moon.dir, atm);
					const float dayFade = Smoothstep(0.02f, 0.65f, dayAmount);
					softShade = LerpSkyColor(Color{ 0, 0, 0, 255 }, localSky, dayFade);
					softShade.a = 255;
				}

				const float lightAng = MoonLightAngleOnBillboard(
					camera, worldPos, moon.dir, sunDir);
				DrawCelestialMoonPhase(
					camera, worldPos, moon.radius, lit, moon.illumination, lightAng, softShade, 28);
			};

			drawMoon(tram);
			drawMoon(fel);
		}
	}

	// --- Sun: path/amber on world el=0; draw until screen terrain skyline ---
	if (overcastDim > 0.05f)
	{
		if (sunEl > drawCullEl - kSunAngularRadiusDeg)
		{
			const Vector3 sunPos = SkyWorldPosFromDir(camera, sunDir);
			const Color noonDisc{ 255, 248, 210, 255 };
			const Color amberDisc{ 255, 150, 60, 255 };
			const Color noonHalo{ 255, 230, 170, 255 };
			const Color amberHalo{ 255, 120, 40, 255 };
			// Full amber at/below 0°; white by +15°.
			const float elAboveLip = std::max(0.0f, sunEl - kWorldHorizonDeg);
			Color disc = HorizonWarmLit(noonDisc, amberDisc, elAboveLip, kSunWarmthElDeg);
			Color halo = HorizonWarmLit(noonHalo, amberHalo, elAboveLip, kSunWarmthElDeg);
			// Opaque core; mild overcast only — no dayAmount / horizon alpha fade.
			disc.a = static_cast<unsigned char>(std::clamp(static_cast<int>(255.0f * overcastDim), 0, 255));
			halo.a = static_cast<unsigned char>(std::clamp(static_cast<int>(110.0f * overcastDim), 0, 140));
			DrawCelestialDisc(camera, sunPos, kSunHaloRadius, halo, 16);
			DrawCelestialDisc(camera, sunPos, kSunDiscRadius, disc, 16);
		}
	}

	rlColor4ub(255, 255, 255, 255);
	rlDrawRenderBatchActive();
	rlEnableDepthMask();
	rlEnableDepthTest();
}

void WeatherSystem::DrawSkyCloudQuads() const
{
	if (CountActiveSkyClouds() == 0)
	{
		return;
	}

	const auto& clouds = g_spriteTable[kCloudSpriteShape];
	if (clouds.empty())
	{
		return;
	}

	// Same continuous dayAmount as sky gradient (dusk + dawn). Soft night floor so
	// fluff stays readable; Clear stays bright, storm band darker gray.
	const float dayAmount = SkyDayAmount();
	const float shade = 0.75f + 0.25f * dayAmount;
	const bool stormTint = SkyFluffUsesStormTint(m_type);
	const float baseR = stormTint ? 130.0f : 245.0f;
	const float baseG = stormTint ? 135.0f : 245.0f;
	const float baseB = stormTint ? 145.0f : 250.0f;
	const unsigned char tr = static_cast<unsigned char>(std::clamp(static_cast<int>(baseR * shade), 0, 255));
	const unsigned char tg = static_cast<unsigned char>(std::clamp(static_cast<int>(baseG * shade), 0, 255));
	const unsigned char tb = static_cast<unsigned char>(std::clamp(static_cast<int>(baseB * shade), 0, 255));

	rlDisableDepthMask();
	BeginShaderMode(g_alphaDiscard);
	BeginBlendMode(BLEND_ALPHA);

	for (const SkyCloud& c : m_skyClouds)
	{
		if (!c.active)
		{
			continue;
		}
		const int idx = c.frame % static_cast<int>(clouds.size());
		const SpriteFrame& cloud = clouds[idx];
		if (cloud.texture.id == 0)
		{
			continue;
		}

		const float age = std::max(0.0f, c.maxLife - c.life);
		const float fadeIn = std::min(1.0f, age / kSkyCloudFadeInSec);
		const float fadeOut = std::min(1.0f, c.life * 0.25f);
		const unsigned char a = static_cast<unsigned char>(
			std::clamp(static_cast<int>(255.0f * c.alpha * fadeIn * fadeOut), 0, 220));
		const Color tint = { tr, tg, tb, a };
		const float aspect = (cloud.height > 0)
			? (static_cast<float>(cloud.width) / static_cast<float>(cloud.height))
			: 1.5f;
		const float halfX = c.size * 0.5f;
		const float halfZ = (c.size / std::max(0.35f, aspect)) * 0.5f;
		DrawTexturedXZQuad(
			cloud.texture,
			Vector3{ c.worldX, c.worldY, c.worldZ },
			halfX,
			halfZ,
			tint);
	}

	EndBlendMode();
	EndShaderMode();
	rlEnableDepthMask();
}

void WeatherSystem::DrawSkyLayer(Camera camera, bool useHemisphereDome)
{
	m_lastCamera = camera;
	m_hasCamera = true;

	if (!WantsOpenSky())
	{
		return;
	}

	// One atmosphere sample for this frame — dome verts and moon silhouettes share it.
	const SkyAtmosphereState atm = BuildSkyAtmosphereState();
	if (useHemisphereDome)
	{
		DrawSkyHemisphere(camera, atm);
	}
	else
	{
		DrawSkyGradient(camera); // title/menu: non-directional panel
	}
	DrawCelestialBodies(camera, atm);
	if (WantsSkyFluff() || CountActiveSkyClouds() > 0)
	{
		DrawSkyCloudQuads();
	}
}

void WeatherSystem::DrawEdgeClouds(Camera camera)
{
	if (IsAvatarSheltered() || CountActiveEdgeClouds() == 0)
	{
		return;
	}

	// Day: dayAmount. Night: moonLightAmount (new moons / overcast → off).
	const float dayAmount = SkyDayAmount();
	const float lightGate = (dayAmount > 0.05f) ? dayAmount : GetMoonLightAmount();
	if (lightGate < 0.05f)
	{
		return;
	}

	const auto& clouds = g_spriteTable[kCloudSpriteShape];
	if (clouds.empty())
	{
		return;
	}

	extern float g_DrawScale;

	for (const EdgeCloud& c : m_edgeClouds)
	{
		if (!c.active)
		{
			continue;
		}
		const int idx = c.frame % static_cast<int>(clouds.size());
		const SpriteFrame& cloud = clouds[idx];
		if (cloud.texture.id == 0)
		{
			continue;
		}

		Vector3 worldPos = { c.worldX, c.worldY, c.worldZ };
		Vector2 screenPos = GetWorldToScreen(worldPos, camera);
		Vector2 screenPosRight = GetWorldToScreen(
			Vector3{ c.worldX + 1.0f, c.worldY, c.worldZ }, camera);
		float pixelsPerUnit = Vector2Distance(screenPos, screenPosRight);
		if (pixelsPerUnit < 1.0f)
		{
			pixelsPerUnit = 1.0f;
		}
		if (g_DrawScale > 0.0f)
		{
			screenPos.x /= g_DrawScale;
			screenPos.y /= g_DrawScale;
			pixelsPerUnit /= g_DrawScale;
		}

		// Slightly larger than precip scale so the shadow covers a readable patch of ground.
		const float scale = (pixelsPerUnit / 8.0f) * 1.6f;
		const float xleft = static_cast<float>(cloud.width - cloud.xOffset - 1);
		const float yabove = static_cast<float>(cloud.height - cloud.yOffset - 1);
		const float drawW = static_cast<float>(cloud.width) * scale;
		const float drawH = static_cast<float>(cloud.height) * scale;
		const float drawX = screenPos.x - xleft * scale;
		const float drawY = screenPos.y - yabove * scale;

		// Texture already carries xform-253 alpha; life + lightGate fade the blot.
		const float lifeFade = std::min(1.0f, c.life * 0.35f);
		const float litFade = lifeFade * lightGate;
		const int alphaFloor = (lightGate >= 0.99f) ? 40 : 0;
		const unsigned char tintA = static_cast<unsigned char>(
			std::clamp(static_cast<int>(255.0f * litFade), alphaFloor, 255));
		if (tintA < 1)
		{
			continue;
		}
		Rectangle source = { 0, 0, static_cast<float>(cloud.width), static_cast<float>(cloud.height) };
		Rectangle dest = { drawX, drawY, drawW, drawH };
		BeginBlendMode(BLEND_ALPHA);
		DrawTexturePro(cloud.texture, source, dest, { 0, 0 }, 0.0f, Color{ 255, 255, 255, tintA });
		EndBlendMode();
	}
}

void WeatherSystem::Draw(Camera camera)
{
	m_lastCamera = camera;
	m_hasCamera = true;

	if (!EffectsEnabled())
	{
		return;
	}

	const bool drawPrecip = ShouldDrawPrecipitation()
		|| (m_type == WeatherType::Rain || m_type == WeatherType::Snow)
		|| (IsFadingOut() && CountActiveParticles() > 0 && m_fallSpeed > 0.0f);
	const bool drawSparkle = (m_type == WeatherType::Sparkle);

	const bool sheltered = IsAvatarSheltered();

	// Ground cloud shadows first; precip/sparkle overlays draw on top so drops
	// are not buried under the blot.
	DrawEdgeClouds(camera);

	if ((drawPrecip || drawSparkle) && !sheltered)
	{
		const auto& frames = g_spriteTable[kPrecipSpriteShape];
		// Sparkle frames vary in size — lock dest to first-frame box so they don't "shrink".
		float sparkleDrawW = 0.0f;
		float sparkleDrawH = 0.0f;
		if (drawSparkle && m_firstFrame >= 0 && m_firstFrame < static_cast<int>(frames.size()))
		{
			sparkleDrawW = static_cast<float>(frames[m_firstFrame].width) * kParticleDrawScale;
			sparkleDrawH = static_cast<float>(frames[m_firstFrame].height) * kParticleDrawScale;
		}

		for (const Particle& p : m_particles)
		{
			if (!p.active)
			{
				continue;
			}

			int frameIndex = 0;
			if (p.splash > 0 && m_useSplashes)
			{
				const int splashLeft = std::max(1, static_cast<int>(p.splash));
				frameIndex = m_firstSplashFrame + (m_splashFrames - splashLeft);
			}
			else if (drawSparkle)
			{
				frameIndex = p.frame;
			}
			else if (m_frameCount > 0)
			{
				frameIndex = m_firstFrame + (p.frame % m_frameCount);
			}
			else
			{
				continue;
			}

			if (frameIndex < 0 || frameIndex >= static_cast<int>(frames.size()))
			{
				continue;
			}

			const SpriteFrame& frame = frames[frameIndex];
			if (frame.texture.id == 0)
			{
				continue;
			}

			float w = static_cast<float>(frame.width) * kParticleDrawScale;
			float h = static_cast<float>(frame.height) * kParticleDrawScale;
			if (drawSparkle && sparkleDrawW > 0.0f && sparkleDrawH > 0.0f)
			{
				w = sparkleDrawW;
				h = sparkleDrawH;
			}
			Rectangle source = { 0, 0, static_cast<float>(frame.width), static_cast<float>(frame.height) };
			Rectangle dest = { p.x, p.y, w, h };

			Color tint = WHITE;
			if (drawSparkle && frame.livePaletteIndex >= 0)
			{
				tint = g_runtimePalette[frame.livePaletteIndex & 255];
				tint.a = 255;
			}

			DrawTexturePro(frame.texture, source, dest, { 0, 0 }, 0.0f, tint);
		}
	}

	if (!sheltered && m_overcastFade > 0.01f && g_isDay)
	{
		const unsigned char a = static_cast<unsigned char>(
			std::clamp(static_cast<int>(kOvercastVeilAlpha * m_overcastFade * OvercastVeilScale(m_intensity)), 0, 255));
		DrawRectangle(0, 0, 640, 360, Color{ 40, 45, 55, a });
	}

	if (!sheltered && m_fogFade > 0.01f)
	{
		// Slightly stronger veil at night so Fog still reads on a dark scene.
		const float nightBoost = g_isDay ? 1.0f : 1.15f;
		const unsigned char a = static_cast<unsigned char>(
			std::clamp(static_cast<int>(kFogVeilAlpha * m_fogFade * nightBoost * m_fogIntensityScale), 0, 255));
		DrawRectangle(0, 0, 640, 360, Color{ 220, 225, 230, a });
	}
}

void WeatherSystem::SyncWeatherMusic()
{
	if (!g_SoundSystem || !EffectsEnabled())
	{
		return;
	}

	StopWeatherMusicIfPlaying();

	int track = -1;
	if (m_type == WeatherType::Rain)
	{
		track = m_music.musicRainTrack;
	}
	else if (m_type == WeatherType::Snow)
	{
		track = m_music.musicSnowTrack;
	}

	if (track < 0)
	{
		return;
	}

	m_activeWeatherMusicPath = BuildU7MusicPath(track);
	g_SoundSystem->PlayMusic(m_activeWeatherMusicPath);
}

void WeatherSystem::StopWeatherMusicIfPlaying()
{
	if (!g_SoundSystem || m_activeWeatherMusicPath.empty())
	{
		m_activeWeatherMusicPath.clear();
		return;
	}

	g_SoundSystem->StopMusic(m_activeWeatherMusicPath);
	m_activeWeatherMusicPath.clear();
}

nlohmann::json WeatherSystem::SaveToJson() const
{
	nlohmann::json j;
	j["type"] = static_cast<int>(m_type);
	j["phase"] = static_cast<int>(m_phase);
	j["intensity"] = static_cast<int>(m_intensity);
	j["remainingMinutes"] = m_remainingMinutes;
	j["hasEggOrigin"] = m_hasEggOrigin;
	j["eggObjectId"] = m_eggObjectId;
	j["eggOrigin"] = { m_eggOrigin.x, m_eggOrigin.y, m_eggOrigin.z };
	j["manualOverride"] = m_manualOverride;
	j["manualOrigin"] = { m_manualOrigin.x, m_manualOrigin.y, m_manualOrigin.z };
	j["musicRainTrack"] = m_music.musicRainTrack;
	j["musicSnowTrack"] = m_music.musicSnowTrack;
	j["targetCount"] = m_targetCount;
	j["bursts"] = m_bursts;
	j["delay"] = m_delay;
	j["direction"] = m_direction;
	j["windDir"] = m_windDir;
	j["windYawDeg"] = m_windYawDeg;
	j["windSpeed"] = static_cast<int>(m_windSpeed);
	j["windSpeedHasOff"] = true;
	j["fogFade"] = m_fogFade;
	j["overcastFade"] = m_overcastFade;
	j["orreryState"] = m_orreryState;
	return j;
}

void WeatherSystem::LoadFromJson(const nlohmann::json& j)
{
	Init();
	if (j.is_null() || !j.is_object())
	{
		return;
	}

	const int type = j.value("type", 0);
	if (type >= 0 && type <= 6)
	{
		m_type = static_cast<WeatherType>(type);
	}
	const int phase = j.value("phase", 0);
	if (phase >= 0 && phase <= 5)
	{
		m_phase = static_cast<WeatherPhase>(phase);
	}
	const int intensity = j.value("intensity", 1);
	if (intensity >= 0 && intensity <= 2)
	{
		m_intensity = static_cast<WeatherIntensity>(intensity);
	}
	m_remainingMinutes = j.value("remainingMinutes", 0);
	m_hasEggOrigin = j.value("hasEggOrigin", false);
	m_eggObjectId = j.value("eggObjectId", -1);
	if (j.contains("eggOrigin") && j["eggOrigin"].is_array() && j["eggOrigin"].size() >= 3)
	{
		m_eggOrigin.x = j["eggOrigin"][0].get<float>();
		m_eggOrigin.y = j["eggOrigin"][1].get<float>();
		m_eggOrigin.z = j["eggOrigin"][2].get<float>();
	}
	m_manualOverride = j.value("manualOverride", false);
	if (j.contains("manualOrigin") && j["manualOrigin"].is_array() && j["manualOrigin"].size() >= 3)
	{
		m_manualOrigin.x = j["manualOrigin"][0].get<float>();
		m_manualOrigin.y = j["manualOrigin"][1].get<float>();
		m_manualOrigin.z = j["manualOrigin"][2].get<float>();
	}
	m_music.musicRainTrack = j.value("musicRainTrack", 4);
	m_music.musicSnowTrack = j.value("musicSnowTrack", 5);
	m_targetCount = j.value("targetCount", 0);
	m_bursts = j.value("bursts", 0);
	m_delay = j.value("delay", 0);
	m_direction = j.value("direction", 0);
	m_windDir = j.value("windDir", m_direction);
	m_windDir = ((m_windDir % 8) + 8) % 8;
	m_direction = m_windDir;
	m_windYawDeg = j.value("windYawDeg", static_cast<float>(m_windDir) * 45.0f);
	while (m_windYawDeg < 0.0f)
	{
		m_windYawDeg += 360.0f;
	}
	while (m_windYawDeg >= 360.0f)
	{
		m_windYawDeg -= 360.0f;
	}
	// New: 0=Off … 3=Heavy. Legacy saves used 0–2 as L/M/H (no Off) → +1.
	if (j.contains("windSpeed"))
	{
		int windSpeed = j["windSpeed"].get<int>();
		if (j.value("windSpeedHasOff", false))
		{
			if (windSpeed >= 0 && windSpeed <= 3)
			{
				m_windSpeed = static_cast<WeatherWindSpeed>(windSpeed);
			}
		}
		else if (windSpeed >= 0 && windSpeed <= 2)
		{
			m_windSpeed = static_cast<WeatherWindSpeed>(windSpeed + 1);
		}
	}
	m_fogFade = j.value("fogFade", 0.0f);
	m_overcastFade = j.value("overcastFade", 0.0f);
	if (j.contains("orreryState"))
	{
		m_orreryState = std::clamp(j.value("orreryState", 9), 0, 9);
	}
	else
	{
		RefreshOrreryStateFromFlags();
	}
	if (m_fogFade > 0.01f)
	{
		m_fogWasActive = true;
	}

	if (m_type == WeatherType::Clear)
	{
		m_phase = WeatherPhase::Idle;
		m_hasEggOrigin = false;
	}
	else
	{
		ConfigureEffectParams(m_type, m_intensity);
		if (m_targetCount <= 0 && m_maxCount > 0 && !IsFadingOut())
		{
			m_targetCount = (m_phase == WeatherPhase::Steady) ? m_maxCount : 1;
		}
		SyncWeatherMusic();
	}
}
