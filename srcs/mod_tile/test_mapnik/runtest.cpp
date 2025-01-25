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

#include <stdexcept>

#include <mapnik/mapnik.hpp>
#include <mapnik/map.hpp>
#include <mapnik/layer.hpp>
#include <mapnik/rule.hpp>
#include <mapnik/feature_type_style.hpp>
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


int main(int ac, char** av)
{
    try
    {

		if (ac != 2)
			throw std::runtime_error("not enough arguments, expected 2\n");
		std::string reg_name = av[1];	
		reg_name = reg_name.substr(0, reg_name.find("."));

		using namespace mapnik;
		mapnik::setup();
		const std::string srs_map = 
			"+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0.0 +x_0=0.0 \
+y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over";
		const std::string srs_layers =
			"+proj=latlon +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0.0 +x_0=0.0 \
+y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over";

        std::cout << " running " << reg_name << "..." << std::endl;
        datasource_cache::instance().register_datasources("/usr/local/lib/mapnik/input/");
        freetype_engine::register_font("/usr/local/lib/mapnik/fonts/DejaVuSans.ttf");

        Map m(1600, 1200);
		std::cout << RED << "Before setting srs_map = " << RST <<  m.srs() << std::endl << std::endl;
        m.set_background(parse_color("#00000000"));
        m.set_srs(srs_map);
		std::cout << RED << "After setting srs_map = " << RST << m.srs() << std::endl << std::endl;
		std::cout << RED << "get_current_extent initial = " << RST << m.get_current_extent() << std::endl << std::endl;
        // create styles

        // Provinces (polygon)
        feature_type_style provpoly_style;
        provpoly_style.reserve(1); // prevent reallocation and copying in add_rule
        {
            rule r;
            //r.set_filter(parse_expression("[NAME_EN] = 'Ontario'"));
            {
                polygon_symbolizer poly_sym;
                put(poly_sym, keys::fill, color(17, 235, 203));
                r.append(std::move(poly_sym));
            }
            provpoly_style.add_rule(std::move(r));
        }
        m.insert_style("provinces", std::move(provpoly_style));

        // Provinces (polyline)
        feature_type_style provlines_style;
        {
            rule r;
	        //r.set_filter(parse_expression("[tags] = 'natural'"));
            {
                line_symbolizer line_sym;
                put(line_sym, keys::stroke, color(0, 0, 0));
                put(line_sym, keys::stroke_width, 1.0);
                dash_array dash;
                dash.emplace_back(8, 4);
                dash.emplace_back(2, 2);
                dash.emplace_back(2, 2);
                put(line_sym, keys::stroke_dasharray, dash);
                r.append(std::move(line_sym));
            }
            provlines_style.add_rule(std::move(r));
        }
        m.insert_style("provlines", std::move(provlines_style));

		//     layers
		{
			parameters p;
			p["type"]="postgis";
			p["host"]="postgres";
			p["port"]="5432";
			p["dbname"]="owm";
			p["user"]="owmuser";
			p["password"]="toor";
			p["table"]=reg_name.append("_region");

            layer lyr("Provinces");
			lyr.set_datasource(datasource_cache::instance().create(p));
            lyr.add_style("provinces");
            lyr.add_style("provlines");
	        lyr.set_srs(srs_layers);

			m.add_layer(lyr);
		}
		// Provincial  polygons

//-54.2536, -36.6291
//        m.zoom_to_box(box2d<double>(-1000000, 4445190, 10000000, 6662941));
//        m.zoom_to_box(box2d<double>(-8024477.28459, 5045190.38849, -7381388.20071, 8062941.44855));
		m.zoom_all();
		std::cout << RED << "get_current_extent(), after zoom_to_box() = " \
		   	<< RST << m.get_current_extent() << std::endl << std::endl;
		std::cout << RED << "get_buffered_extent(), after zoom_to_box() = " \
		   	<< RST << m.get_buffered_extent() << std::endl << std::endl;

        image_rgba8 buf(m.width(), m.height());
		std::cout << RED << "m.width() = " << RST << m.width() << std::endl;
		std::cout << RED << "m.height() = " << RST << m.height() \
		   	<< std::endl << std::endl;
		//std::cout << RED << "m.get_extra_parameters() = " << RST \
		   	<< m.get_extra_parameters().get("proj") << std::endl << std::endl;
		//std::cout << RED << "m.get_layer() = " << RST \
		   	<< m.get_layer() << std::endl << std::endl;

        agg_renderer<image_rgba8> ren(m, buf);
		std::cout << RED << "get_current_extent(), after agg_render() = " \
		   	<< RST << m.get_current_extent() << std::endl << std::endl;
        ren.apply();
        std::string msg("These maps have been rendered using AGG in the current directory:\n");
#ifdef HAVE_PNG
        save_to_file(buf, "demo.png", "png");
        msg += "- demo.png\n";
#endif
        msg += "Have a look!\n";
        std::cout << msg;

        save_map(m, reg_name.append(".xml"));
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
