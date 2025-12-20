#include <Geist/Logging.h>
#include <memory>
#include <fstream>
#include <iomanip>
#include <ctime>
#include <chrono>
#include <iostream>
#include <unordered_map>

using namespace std;
using namespace std::chrono;

string logfile = "runlog.txt";

void SetLogFileName(string filename)
{
	logfile = filename;
}

string GetLogFileName()
{
	return logfile;
}

void Log(string text, string filename, bool suppressDateTime)
{
	// Use global logfile if filename is empty
	if (filename.empty())
	{
		filename = logfile;
	}

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
#ifdef DEBUG_MODE
		cout << text << endl;
#endif
		*logstreams[filename] << text << endl;
#ifdef DEBUG_MODE
		logstreams[filename]->flush();
#endif
	}
	else
	{
		auto now = system_clock::now();
		auto ms = duration_cast<milliseconds>(now.time_since_epoch()) % 1000;
		auto timer = system_clock::to_time_t(now);
#ifdef DEBUG_MODE
		cout << " " << std::put_time(std::localtime(&timer), "%c") << '.' << std::setfill('0') << std::setw(3) << ms.count() << " " << text << endl;
#endif
		*logstreams[filename] << " " << std::put_time(std::localtime(&timer), "%c") << '.' << std::setfill('0') << std::setw(3) << ms.count() << " " << text << endl;
#ifdef DEBUG_MODE
		logstreams[filename]->flush();
#endif
	}
}
