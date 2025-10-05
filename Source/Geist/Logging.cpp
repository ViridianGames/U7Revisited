#include "Logging.h"
#include <memory>
#include <fstream>
#include <iomanip>
#include <ctime>
#include <chrono>
#include <iostream>
#include <unordered_map>

using namespace std;
using namespace std::chrono;

string logfile = "";

void Log(string text, string filename, bool suppressDateTime)
{
	static unordered_map<std::string, unique_ptr<ofstream> > logstreams;

	if (logstreams.find(filename) == logstreams.end())
	{
		logstreams[filename] = make_unique<ofstream>();
	}

	if (!logstreams[filename]->is_open())
	{
		logstreams[filename]->open(filename);
	}

	if (suppressDateTime)
	{
		cout << text << endl;
		*logstreams[filename] << text << endl;
		logstreams[filename]->flush();
	}
	else
	{
		auto now = system_clock::now();
		auto ms = duration_cast<milliseconds>(now.time_since_epoch()) % 1000;
		auto timer = system_clock::to_time_t(now);
		cout << " " << std::put_time(std::localtime(&timer), "%c") << '.' << std::setfill('0') << std::setw(3) << ms.count() << " " << text << endl;
		*logstreams[filename] << " " << std::put_time(std::localtime(&timer), "%c") << '.' << std::setfill('0') << std::setw(3) << ms.count() << " " << text << endl;
		logstreams[filename]->flush();
	}
}
