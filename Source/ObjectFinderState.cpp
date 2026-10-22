#include "Geist/Globals.h"
#include "Geist/Engine.h"
#include "Geist/StateMachine.h"
#include "Geist/ResourceManager.h"
#include "U7Globals.h"
#include "ObjectFinderState.h"

#include <algorithm>
#include <map>
#include <set>

#include "InputSystem.h"

using namespace std;

void ObjectFinderState::Init(const string& configfile)
{
	m_gui.m_Font = g_guiFont;
	m_gui.SetLayout(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, g_DrawScale, Gui::GUIP_USE_XY);

	m_gui.AddOctagonBox(GE_PANEL, 4, 4, 276, 352, g_Borders);
	m_gui.AddTextArea(GE_TITLE, g_guiFont.get(), "Object Finder", 12, 11);
	m_gui.AddTextInput(GE_SEARCH, 12, 24, 260, 11, g_guiFont.get(), "")->m_FormatNumbers = false;
	m_gui.AddListBox(GE_MATCHES, 12, 40, 260, 150, g_guiFont.get());
	m_gui.AddListBox(GE_INSTANCES, 12, 196, 260, 106, g_guiFont.get());
	m_gui.AddStretchButton(GE_JUMP, 12, 306, 40, "Jump",
		g_ShapeButtonL, g_ShapeButtonR, g_ShapeButtonM, g_ShapeButtonL, g_ShapeButtonR, g_ShapeButtonM);
	m_gui.AddStretchButton(GE_TELEPORT, 58, 306, 80, "Teleport Party",
		g_ShapeButtonL, g_ShapeButtonR, g_ShapeButtonM, g_ShapeButtonL, g_ShapeButtonR, g_ShapeButtonM);
	m_gui.AddTextArea(GE_LEGENDWORLD, g_guiFont.get(), "In world", 154, 309, 0, 0, MAGENTA);
	m_gui.AddTextArea(GE_LEGENDCONTAINER, g_guiFont.get(), "In container", 204, 309, 0, 0, YELLOW);
	m_gui.AddTextArea(GE_KEYSHELP, g_guiFont.get(), "Enter: jump   Esc: close and clear the results", 12, 322);
	m_gui.AddTextArea(GE_GAMEHELP, g_guiFont.get(), "Back in the game, F3 / Shift+F3: next / previous", 12, 332);
	m_gui.AddTextArea(GE_MAPHELP, g_guiFont.get(), "Map: wheel zooms, right-drag pans, click a dot to jump", 12, 342);

	m_gui.AddOctagonBox(GE_MAPBORDER, 284, 4, 352, 352, g_Borders);

	m_map = g_ResourceManager->GetTexture("Images/minimap.png");
}

void ObjectFinderState::OnEnter()
{
	SetFirstPersonMouseLook(false);
	BuildEntries();

	static_cast<GuiTextInput*>(m_gui.GetElement(GE_SEARCH).get())->m_String = "";
	m_lastSearch = "";
	ShowInstances(-1);
	UpdateMatches();

	//  Start out showing the whole world
	Rectangle map = GetMapRect();
	m_mapCamera = { { map.x, map.y }, { 0, 0 }, 0, map.width / 3072.0f };
}

//  One entry per name: shape names (plus frame names like reagents) and NPC names
void ObjectFinderState::BuildEntries()
{
	m_entries.clear();
	map<string, int> entryForLabel;

	for (auto& [id, object] : g_objectList)
	{
		if (object->m_shapeData == nullptr || GetOutermostContainer(object.get()) == nullptr)
		{
			continue;
		}

		//  Frame names (black pearl, bread...) replace the shape's own name, so list both; frame -1 gives the shape's name
		int shape = object->m_shapeData->GetShape();
		set<string> labels = { GetShapeFrameName(shape, object->m_shapeData->GetFrame()) + " (" + to_string(shape) + ")",
			GetShapeFrameName(shape, -1) + " (" + to_string(shape) + ")" };
		if (object->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC && !object->m_name.empty())
		{
			labels.insert(object->m_name + " (NPC " + to_string(object->m_NPCID) + ")");
		}

		for (const string& label : labels)
		{
			auto [found, added] = entryForLabel.emplace(label, int(m_entries.size()));
			if (added)
			{
				m_entries.push_back({ label, {} });
			}
			m_entries[found->second].objectIds.push_back(id);
		}
	}

	sort(m_entries.begin(), m_entries.end(), [](const Entry& a, const Entry& b) { return a.label < b.label; });
}

//  Rank the entries by how well every typed word matches their label; ties stay alphabetical
void ObjectFinderState::UpdateMatches()
{
	vector<string> typedWords = GetSearchWords(m_lastSearch);
	vector<pair<float, int>> ranked;
	for (int i = 0; i < int(m_entries.size()); ++i)
	{
		vector<string> words = GetSearchWords(m_entries[i].label);
		float score = 0;
		for (const string& typed : typedWords)
		{
			score += GetSearchWordScore(typed, words);
		}
		if (score > 0 || typedWords.empty())
		{
			ranked.push_back({ score, i });
		}
	}
	stable_sort(ranked.begin(), ranked.end(), [](const pair<float, int>& a, const pair<float, int>& b) { return a.first > b.first; });

	GuiListBox* matchList = static_cast<GuiListBox*>(m_gui.GetElement(GE_MATCHES).get());
	matchList->Clear();
	m_matches.clear();
	for (const auto& [score, entry] : ranked)
	{
		m_matches.push_back(entry);
		matchList->AddItem(m_entries[entry].label + "  x" + to_string(m_entries[entry].objectIds.size()));
	}
	matchList->SetSelectedIndex(typedWords.empty() ? -1 : 0);
}

//  List an entry's instances, nearest to the camera first
void ObjectFinderState::ShowInstances(int entry)
{
	m_shownEntry = entry;
	m_hoveredInstance = -1;

	GuiListBox* instanceList = static_cast<GuiListBox*>(m_gui.GetElement(GE_INSTANCES).get());
	instanceList->Clear();
	if (entry < 0)
	{
		return;
	}

	//  Scripts keep running while the finder is open, so instances can vanish
	vector<int>& ids = m_entries[entry].objectIds;
	ids.erase(remove_if(ids.begin(), ids.end(), [](int id) { return GetOutermostContainer(GetObjectFromID(id)) == nullptr; }), ids.end());
	sort(ids.begin(), ids.end(), [](int a, int b)
	{
		return Vector3DistanceSqr(GetOutermostContainer(GetObjectFromID(a))->m_Pos, g_camera.target) <
			Vector3DistanceSqr(GetOutermostContainer(GetObjectFromID(b))->m_Pos, g_camera.target);
	});

	for (int i = 0; i < int(ids.size()); ++i)
	{
		U7Object* placed = GetPlacedInstance(i);
		string row = to_string(int(placed->m_Pos.x)) + ", " + to_string(int(placed->m_Pos.z));
		if (placed->m_ID != ids[i])
		{
			row += "  in " + (placed->m_UnitType == U7Object::UnitTypes::UNIT_TYPE_NPC ? placed->m_name : GetObjectDisplayName(placed));
		}
		instanceList->AddItem(row);
	}
}

void ObjectFinderState::Update()
{
	m_gui.Update();

	GuiTextInput* search = static_cast<GuiTextInput*>(m_gui.GetElement(GE_SEARCH).get());
	GuiListBox* matchList = static_cast<GuiListBox*>(m_gui.GetElement(GE_MATCHES).get());
	GuiListBox* instanceList = static_cast<GuiListBox*>(m_gui.GetElement(GE_INSTANCES).get());

	//  Esc also takes the old results off the minimap
	if (IsKeyPressed(KEY_ESCAPE))
	{
		g_mainState->m_finderObjectIds.clear();
		g_StateMachine->PopState();
		return;
	}

	if (search->m_String != m_lastSearch)
	{
		m_lastSearch = search->m_String;
		UpdateMatches();
	}

	if (IsKeyPressed(KEY_DOWN))
	{
		matchList->SetSelectedIndex(matchList->GetSelectedIndex() + 1);
	}

	if (IsKeyPressed(KEY_UP) && matchList->GetSelectedIndex() > 0)
	{
		matchList->SetSelectedIndex(matchList->GetSelectedIndex() - 1);
	}

	int selectedMatch = matchList->GetSelectedIndex();
	int entry = (selectedMatch >= 0) ? m_matches[selectedMatch] : -1;
	if (entry != m_shownEntry)
	{
		ShowInstances(entry);
	}

	//  Map: the wheel zooms around the mouse, the right button pans
	Rectangle map = GetMapRect();
	Vector2 mouse = GetMousePosition();
	if (CheckCollisionPointRec(mouse, map))
	{
		float wheel = GetMouseWheelMove();
		if (wheel != 0)
		{
			m_mapCamera.target = GetScreenToWorld2D(mouse, m_mapCamera);
			m_mapCamera.offset = mouse;
			m_mapCamera.zoom = Clamp(m_mapCamera.zoom * (wheel > 0 ? 1.25f : 0.8f), map.width / 3072.0f, 8.0f);

			//  Fully zoomed out shows the whole world again
			if (m_mapCamera.zoom == map.width / 3072.0f)
			{
				m_mapCamera = { { map.x, map.y }, { 0, 0 }, 0, map.width / 3072.0f };
			}
		}

		if (IsMouseButtonDown(MOUSE_BUTTON_RIGHT))
		{
			m_mapCamera.target = Vector2Subtract(m_mapCamera.target, Vector2Scale(GetMouseDelta(), 1.0f / m_mapCamera.zoom));
		}
	}
	m_hoveredInstance = GetInstanceUnderMouse();

	//  Jump to the picked instance, or the nearest one if none is picked
	if (!instanceList->m_Items.empty())
	{
		int instance = max(instanceList->GetSelectedIndex(), 0);
		if (m_gui.GetActiveElementID() == GE_TELEPORT)
		{
			Jump(instance, true);
		}
		else if (IsKeyPressed(KEY_ENTER) || IsKeyPressed(KEY_KP_ENTER) || matchList->m_DoubleClicked || instanceList->m_DoubleClicked
			|| m_gui.GetActiveElementID() == GE_JUMP)
		{
			Jump(instance, false);
		}
		else if (m_hoveredInstance >= 0 && g_InputSystem->WasLButtonClicked())
		{
			Jump(m_hoveredInstance, false);
		}
	}

	//  Typing always goes to the search box
	search->m_HasFocus = true;
	m_gui.m_ActiveElement = GE_SEARCH;
}

void ObjectFinderState::Jump(int instance, bool teleport)
{
	g_mainState->m_finderLabel = m_entries[m_shownEntry].label;
	g_mainState->m_finderObjectIds = m_entries[m_shownEntry].objectIds;
	g_mainState->JumpToFinderResult(instance);

	U7Object* placed = GetPlacedInstance(instance);
	if (teleport && placed != nullptr)
	{
		TeleportPartyTo(int(placed->m_Pos.x), int(placed->m_Pos.z));
		LockCameraToAvatar();
	}

	g_StateMachine->PopState();
}

U7Object* ObjectFinderState::GetPlacedInstance(int instance)
{
	return GetOutermostContainer(GetObjectFromID(m_entries[m_shownEntry].objectIds[instance]));
}

int ObjectFinderState::GetInstanceUnderMouse()
{
	if (m_shownEntry < 0 || !CheckCollisionPointRec(GetMousePosition(), GetMapRect()))
	{
		return -1;
	}

	int closest = -1;
	float closestDistance = 4 * g_DrawScale;
	for (int i = 0; i < int(m_entries[m_shownEntry].objectIds.size()); ++i)
	{
		U7Object* placed = GetPlacedInstance(i);
		if (placed == nullptr)
		{
			continue;
		}
		float distance = Vector2Distance(GetWorldToScreen2D({ placed->m_Pos.x, placed->m_Pos.z }, m_mapCamera), GetMousePosition());
		if (distance < closestDistance)
		{
			closest = i;
			closestDistance = distance;
		}
	}
	return closest;
}

//  Screen-space rectangle inside the map border
Rectangle ObjectFinderState::GetMapRect()
{
	return { 288 * g_DrawScale, 8 * g_DrawScale, 344 * g_DrawScale, 344 * g_DrawScale };
}

void ObjectFinderState::Draw()
{
	BeginTextureMode(g_guiRenderTarget);
	ClearBackground({ 0, 0, 0, 0 });

	DrawRectangle(0, 0, g_Engine->m_RenderWidth, g_Engine->m_RenderHeight, Color{ 0, 0, 0, 128 });
	m_gui.Draw();

	EndTextureMode();

	DrawTexturePro(g_guiRenderTarget.texture,
		{ 0, 0, float(g_guiRenderTarget.texture.width), float(g_guiRenderTarget.texture.height) },
		{ 0, float(g_Engine->m_ScreenHeight), float(g_Engine->m_ScreenWidth), -float(g_Engine->m_ScreenHeight) },
		{ 0, 0 }, 0, WHITE);

	//  The map is drawn at screen resolution so it stays sharp when zoomed in
	Rectangle map = GetMapRect();
	BeginScissorMode(int(map.x), int(map.y), int(map.width), int(map.height));
	BeginMode2D(m_mapCamera);

	DrawTexturePro(*m_map, { 0, 0, float(m_map->width), float(m_map->height) }, { 0, 0, 3072, 3072 }, { 0, 0 }, 0, WHITE);

	if (m_shownEntry >= 0)
	{
		const vector<int>& ids = m_entries[m_shownEntry].objectIds;
		float pixel = g_DrawScale / m_mapCamera.zoom;  // One GUI pixel in world tiles
		for (int i = 0; i < int(ids.size()); ++i)
		{
			U7Object* placed = GetPlacedInstance(i);
			if (placed == nullptr)
			{
				continue;
			}
			Color color = (placed->m_ID == ids[i]) ? MAGENTA : YELLOW;
			DrawRectangleV({ placed->m_Pos.x - 2 * pixel, placed->m_Pos.z - 2 * pixel }, { 4 * pixel, 4 * pixel }, BLACK);
			DrawRectangleV({ placed->m_Pos.x - pixel, placed->m_Pos.z - pixel }, { 2 * pixel, 2 * pixel }, color);
		}

		//  Ring the hovered instance, or the one picked in the list
		int instanceRow = static_cast<GuiListBox*>(m_gui.GetElement(GE_INSTANCES).get())->GetSelectedIndex();
		int ringed = (m_hoveredInstance >= 0) ? m_hoveredInstance : instanceRow;
		U7Object* placed = (ringed >= 0) ? GetPlacedInstance(ringed) : nullptr;
		if (placed != nullptr)
		{
			DrawRing({ placed->m_Pos.x, placed->m_Pos.z }, 5 * pixel, 6 * pixel, 0, 360, 32, WHITE);
		}
	}

	EndMode2D();
	EndScissorMode();

	//  Name the hovered dot
	if (m_hoveredInstance >= 0)
	{
		string text = static_cast<GuiListBox*>(m_gui.GetElement(GE_INSTANCES).get())->m_Items[m_hoveredInstance];
		float size = g_guiFont->baseSize * g_DrawScale;
		Vector2 position = Vector2Add(GetMousePosition(), { 14 * g_DrawScale, 4 * g_DrawScale });
		Vector2 textSize = MeasureTextEx(*g_guiFont, text.c_str(), size, g_DrawScale);
		DrawRectangleV(Vector2Subtract(position, { g_DrawScale, g_DrawScale }), Vector2Add(textSize, { 2 * g_DrawScale, 2 * g_DrawScale }), Color{ 0, 0, 0, 192 });
		DrawTextEx(*g_guiFont, text.c_str(), position, size, g_DrawScale, WHITE);
	}
}
