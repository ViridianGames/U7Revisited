//  TODO - Write out config files in the same order they are read in, or as
//  close as possible.

#include "Config.h"
#include "Logging.h"
#include <string>
#include <sstream>
#include <fstream>

using namespace std;

bool Config::Load(string fileName)
{
   string line, leftside, rightside;

   ifstream instream(fileName.c_str());

   if (instream.fail())
   {
      Log("Could not open " + fileName);
      return false;
   }

   m_FileName = fileName;

   m_Config.clear();

   do
   {
      getline(instream, line);

#ifdef _WINDOWS
#else
      if (line.size() > 0)
      {
         if (line.at(line.size() - 1) == '\r')
         {
            line = line.substr(0, line.size() - 1);
         }
      }
#endif      

      string::size_type idx = line.find('=');

      if (idx != string::npos)
      {
         leftside = line.substr(0, idx - 1);
         rightside = line.substr(idx + 2);

         bool isNumber = false;

         istringstream numbertest(rightside);

         unsigned int numtest;
         numbertest >> numtest;

         if (!numbertest)
         {
            isNumber = false;
         }
         else
         {
            isNumber = true;
         }

         if (isNumber)
         {
            ConfigInfo temp;
            temp.datatype = DATA_NUMBER;
            temp.numdata = float(atof(rightside.c_str()));
            temp.stringdata = "";
            m_Config.insert(make_pair(leftside, temp));
            m_StringsInOrder.emplace_back(leftside);
         }
         else
         {
            ConfigInfo temp;
            temp.datatype = DATA_STRING;
            temp.stringdata = rightside;
            temp.numdata = 0;
            m_Config.insert(make_pair(leftside, temp));
            m_StringsInOrder.emplace_back(leftside);
         }
      }
      else
      {
         m_StringsInOrder.emplace_back(line);
      }
   } while (!instream.eof());

   instream.close();

   return true;
}

void Config::Save()
{
   Save(m_FileName);
}

void Config::Save(string filename)
{
   if (filename != m_FileName)
      m_FileName = filename;

   ofstream outstream(m_FileName);

   if (outstream.fail())
   {
      throw ("Could not open " + m_FileName);
   }

   //  Write the config file out in a format that can be re-read next time.
   int size = int(m_StringsInOrder.size() - 1);
   int index = 0;
   for (const auto node : m_StringsInOrder)
   {
      outstream << node;
      if (m_Config.find(node) != m_Config.end())
      {
         if (m_Config[node].datatype == DATA_NUMBER)
            outstream << " = " << m_Config[node].numdata;
         else if (m_Config[node].datatype == DATA_STRING)
            outstream << " = " << m_Config[node].stringdata;
      }

	  if (index != size)
	  {
		  outstream << endl;
	  }
	  ++index;
   }

   outstream.close();
}

float Config::GetNumber(string node)
{
   if (m_Config[node].datatype == DATA_NUMBER)
   {
      return m_Config[node].numdata;
   }
   else
   {
      return 0;
   }
}

string Config::GetString(string node)
{
   if (m_Config[node].datatype == DATA_STRING)
   {
      return m_Config[node].stringdata;
   }
   else
   {
      return "";
   }
}

void Config::SetNumber(std::string node, float number)
{
   if (m_Config.find(node) != m_Config.end() && m_Config.find(node)->second.datatype == DATA_NUMBER)
   {
      m_Config[node].numdata = number;
   }
   else
   {
      ConfigInfo temp;
      temp.datatype = DATA_NUMBER;
      temp.numdata = number;
      m_Config[node] = temp;
      m_StringsInOrder.emplace_back(node);
   }
}

void Config::SetString(std::string node, std::string name)
{
   if (m_Config.find(node) != m_Config.end() && m_Config.find(node)->second.datatype == DATA_STRING)
   {
      m_Config[node].stringdata = name;
   }
   else
   {
      ConfigInfo temp;
      temp.datatype = DATA_STRING;
      temp.stringdata = name;
      m_Config[node] = temp;
      m_StringsInOrder.emplace_back(node);
   }
}