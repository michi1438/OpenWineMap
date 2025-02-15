#ifndef __Region_hpp__
# define __Region_hpp__

# include <iostream>
# include <fstream>
# include <vector>

class    Region
{
	private:
		std::string Name;
		std::vector<std::string> Appelations;
		int Size;

	public:
		Region(std::string name);
		Region(void);
		Region(const Region& other);
		~Region(void);

		int getSize(void);
		std::vector<std::string> getAppelations(void);
		std::string getName(void);
};

#endif //__Region_hpp__
