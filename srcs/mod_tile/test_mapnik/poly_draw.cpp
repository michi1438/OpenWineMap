/*****************************************************************************
 *
 * This file is part of Mapnik (c++ mapping toolkit)
 *
 * Copyright (C) 2024 Artem Pavlenko
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 *****************************************************************************/

#include "Region.hpp"

#include <mapnik/mapnik.hpp>
#include <mapnik/map.hpp>
#include <mapnik/layer.hpp>
#include <mapnik/featureset.hpp>
#include <mapnik/rule.hpp>
#include <mapnik/feature_type_style.hpp>
#include <mapnik/datasource.hpp>
#include <mapnik/symbolizer.hpp>
#include <mapnik/text/placements/dummy.hpp>
#include <mapnik/text/text_properties.hpp>
#include <mapnik/text/formatting/text.hpp>
#include <mapnik/datasource_cache.hpp>
#include <mapnik/font_engine_freetype.hpp>
#include <mapnik/agg_renderer.hpp>
#include <mapnik/expression.hpp>
#include <mapnik/color_factory.hpp>
#include <mapnik/image_util.hpp>
#include <mapnik/unicode.hpp>
#include <mapnik/save_map.hpp>
#include <mapnik/cairo_io.hpp>

#if defined(HAVE_CAIRO)
#include <mapnik/cairo/cairo_renderer.hpp>
#include <mapnik/cairo/cairo_image_util.hpp>
#endif

#define RED "\x1B[31m"
#define RST "\x1B[0m"

#include <iostream>
#include <stdexcept>
#include <vector>


int main(int ac, char** av)
{
    try
    {
		if (ac != 2)
			throw std::runtime_error("not enough arguments, expected 1\n");
		std::string reg_name = av[1];	
		std::string db_user = getenv("DB_USER");
		std::string db_host = getenv("DB_HOST");
		std::string db_user_pw = getenv("DB_USER_PW");
		std::string db_port = getenv("DB_PORT");
		std::string db_name = getenv("DB_NAME");

		using namespace mapnik;
		mapnik::setup();
		const std::string srs_map = 
			"+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0.0 +x_0=0.0 \
+y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over";
		const std::string srs_layers =
			"+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0.0 +x_0=0.0 \
+y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over";

        std::cout << " running poly_draw.out for " << reg_name << "..." << std::endl;
        datasource_cache::instance().register_datasources("/usr/local/lib/mapnik/input/");
        freetype_engine::register_font("/usr/local/lib/mapnik/fonts/DejaVuSans.ttf");

        Map m(800, 600);
        m.set_background(parse_color("#00000000"));
        m.set_srs(srs_map);

		Region appl(av[1]);

		parameters p;
		p["type"]="postgis";
		p["host"]=db_host;
		p["port"]=db_port;
		p["dbname"]=db_name;
		p["user"]=db_user;
		p["password"]=db_user_pw;
		p["table"]="ww_appelations";

		for (int i = 0; i < appl.getSize() ; i++)
		{
			layer lyr("Provinces");
			lyr.set_datasource(datasource_cache::instance().create(p));

			lyr.add_style(appl.getAppelations()[i]);
			lyr.set_srs(srs_layers);

			m.add_layer(lyr);
		}
		m.zoom_all();
		//std::cout << "current_extent = " << m.get_current_extent() << std::endl;
		//std::cout << "buffered_extent = " << m.get_buffered_extent() << std::endl;

		feature_type_style provpoly_style[appl.getSize()];
		for (int i = 0; i < appl.getSize(); i++)
		{
			provpoly_style[i].reserve(1);
			{
				rule r;
				r.set_filter(parse_expression("[name] = \"AOP_" + appl.getAppelations()[i]+ "\" and [zaxis] = 15"));
				{
					polygon_symbolizer poly_sym;
					put(poly_sym, keys::fill, color(100, 0 + (i*15)%255, 80));
					r.append(std::move(poly_sym));
				}
				provpoly_style[i].add_rule(std::move(r));
				rule r2;
				r2.set_filter(parse_expression("[name] = \"AOP_" + appl.getAppelations()[i]+ "\" and [zaxis] = 10"));
				{
					polygon_symbolizer poly_sym;
					put(poly_sym, keys::fill, color(100, 25 + (i*15)%255, 100));
					r2.append(std::move(poly_sym));
				}
				provpoly_style[i].add_rule(std::move(r2));
				rule r3;
				r3.set_filter(parse_expression("[name] = \"AOP_" + appl.getAppelations()[i]+ "\" and [zaxis] = 5"));
				{
					polygon_symbolizer poly_sym;
					put(poly_sym, keys::fill, color(100, 50 + (i*15)%255, 120));
					r3.append(std::move(poly_sym));
				}
				provpoly_style[i].add_rule(std::move(r3));
			}
	//		provpoly_style[i].set_comp_op(overlay);
			m.insert_style(appl.getAppelations()[i], std::move(provpoly_style[i]));
		}

        image_rgba8 buf(m.width(), m.height());
        agg_renderer<image_rgba8> ren(m, buf);

        ren.apply();
        std::string msg("These maps have been rendered using AGG in the current directory:\n");
#ifdef HAVE_PNG
        save_to_file(buf, "demo.png", "png");
        msg += "- demo.png\n";
#endif
        msg += "Have a look!\n";
        std::cout << msg;

        save_map(m, "/home/" + db_user + "/src/openstreetmap-carto/" + reg_name + ".xml");
        std::cout << "XML output at: /home/" + db_user + "/src/openstreetmap-carto/" + reg_name + ".xml" << std::endl;
    }
    catch (std::exception const& ex)
    {
        std::cerr << std::endl << "### std::exception: " << ex.what() << std::endl;
        return EXIT_FAILURE;
    }
    catch (...)
    {
        std::cerr << "### Unknown exception." << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
