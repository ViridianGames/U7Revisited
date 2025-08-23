#include "Logging.h"
#include <memory>
#include <fstream>
#include <iomanip>
#include <ctime>
#include <chrono>
#include <iostream>

using namespace std;
using namespace std::chrono;

string logfile = "";

void Log(string text)
{
	static unique_ptr<ofstream> logstream = make_unique<ofstream>();

	if (!logstream->is_open())
	{
		logstream->open("runlog.txt", ofstream::app);
	}

	auto now = system_clock::now();
	auto ms = duration_cast<milliseconds>(now.time_since_epoch()) % 1000;
	auto timer = system_clock::to_time_t(now);
	cout << " " << std::put_time(std::localtime(&timer), "%c") << '.' << std::setfill('0') << std::setw(3) << ms.count() << " " << text << endl;
	*logstream << " " << std::put_time(std::localtime(&timer), "%c") << '.' << std::setfill('0') << std::setw(3) << ms.count() << " " << text << endl;
	logstream->flush();
}
