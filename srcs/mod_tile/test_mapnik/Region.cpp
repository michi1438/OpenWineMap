#include "Region.hpp"

//cdc

Region::Region(std::string name)
{
	std::string db_user = getenv("DB_USER");
	this->Name = name;
	std::ifstream input("/home/" + db_user + "/db_connect/" + this->Name + "_data");
	std::string line;
	while (std::getline(input, line))
	{
		if (line.find("[AOP]") == 0)
			this->Appelations.push_back(line.substr(5));
	}
	this->Size = Appelations.size();
}

Region::Region(void) {}

Region::~Region(void)
{
	std::cout << this->Name << " destructor called !" << std::endl;
}

Region::Region(const Region& other)
{
	*this = other;
}

//getters

std::string Region::getName(void)
{
	return (this->Name);
}

std::vector<std::string> Region::getAppelations(void)
{
	return (this->Appelations);
}

int Region::getSize(void)
{
	return (this->Size);
}
