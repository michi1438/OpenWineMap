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
#include <stdexcept>
#include <vector>


int main(int ac, char** av)
{
    try
    {
		if (ac != 1)
			throw std::runtime_error("not enough arguments, expected 2\n");
		std::string reg_name = av[0];	
		reg_name = reg_name.substr(0, reg_name.find("."));

		using namespace mapnik;
		mapnik::setup();
		const std::string srs_map = 
			"+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0.0 +x_0=0.0 \
+y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over";
		const std::string srs_layers =
			"+proj=merc +a=6378137 +b=6378137 +lat_ts=0 +lon_0=0.0 +x_0=0.0 \
+y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over";
        std::cout << " running aquitaine" << reg_name << "..." << std::endl;
        datasource_cache::instance().register_datasources("/usr/local/lib/mapnik/input/");
        freetype_engine::register_font("/usr/local/lib/mapnik/fonts/DejaVuSans.ttf");

        Map m(1600, 1200);
        m.set_background(parse_color("#00000000"));
        m.set_srs(srs_map);

		//std::vector<std::string> commune[2];
		//commune[0] = {"Aincille", "Anhaux", "Ascarat", "Bidarray", "Bussunarits-Sarrasquette", "Bustince-Iriberry", "Irouléguy", "Ispoure", "Jaxu", "Lasse", "Lecumberry", "Ossès", "Saint-Etienne-de-Baïgorry", "Saint-Jean-le-Vieux", "Saint-Martin-d’Arrossa"};
		//commune[1] = {"Maumusson-Laguian", "Riscle", "Cannet", "Viella", "Castelnau-Rivière-Basse", "Hagedet", "Lascazères", "Madiran", "Saint-Lanne et Soublecause", "Abos", "Arbus", "Arricau-Bordes", "Arrosès", "Artiguelouve", "Aubertin", "Aubous", "Aurions-Idernes", "Aydie", "Baigts-de-Béarn", "Bellocq", "Bérenx", "Bétracq", "Bosdarros", "Burosse-Mendousse", "Cadillon", "Cardesse", "Carresse", "Castagnède", "Castetpugon", "Castillon (Canton de Lembeye)", "Conchez-de-Béarn", "Corbères-Abères", "Crouseilles", "Cuqueron", "Diusse", "Escurès", "Estialescq", "Gan", "Gayon", "Gelos", "Haut-de-Bosdarros", "L’Hôpital-d’Orion", "Jurançon", "Lacommande", "Lagor", "Lahontan", "Lahourcade", "Laroin", "Lasserre", "Lasseube", "Lasseubetat", "Lembeye", "Lespielle-Germenaud-Lannegrasse", "Lucq-de-Béarn", "Mascaraàs-Haron", "Mazères-Lezons", "Moncaup", "Moncla", "Monein", "Monpezat", "Mont-Disse", "Mourenx", "Narcastet", "Ogenne-Camptort", "Oraàs", "Orthez", "Parbayse", "Portet", "Puyoo", "Ramous", "Rontignon", "Saint-Faust", "Saint-Jean-Poudge", "Salies-de-Béarn", "Salles-Mongiscard", "Sauvelade", "Séméacq-Blachon", "Tadon-Sadirac-Viellenave", "Tadousse-Ussau", "Uzos", "Vialer", "Vielleségure"};
		//std::string commune_irouleguy = "[name] = '";
		//std::cout << RED << "comune_str = " << RST << std::endl;
		//for (std::string n : commune[0])
		//{
		//	std::cout << n << std::endl;
		//	commune_irouleguy.append(n);
		//	commune_irouleguy.append("'");
		//	if (n != commune[0].back())
		//		commune_irouleguy.append(" or [name] = '");
		//}
		//std::cout << std::endl;

		std::vector<std::string> appelation = {"bearne", "madiran", "jurancon", "irouleguy"};
		// Provinces (polygon)
		feature_type_style provpoly_style[4];
		feature_type_style appelation_style[4];
		for (int i = 0; i < 4; i++)
		{
			provpoly_style[i].reserve(1); // prevent reallocation and copying in add_rule
			{
				rule r;
				r.set_filter(parse_expression("[name] = 'the_whole_appelation'"));
				{
					polygon_symbolizer poly_sym;
					put(poly_sym, keys::fill, color(17, 235, 60+(i*60), 0x80));
					r.append(std::move(poly_sym));
				}
				provpoly_style[i].add_rule(std::move(r));
			}
			m.insert_style(appelation[i], std::move(provpoly_style[i]));

			appelation_style[i].reserve(1); // prevent reallocation and copying in add_rule
			{
				rule r;
				//r.set_filter(parse_expression(commune_irouleguy + " or " + commune_bearne));
				r.set_filter(parse_expression("[name] = 'the_whole_appelation'"));
				r.set_max_scale(346775);
				{
					line_symbolizer line_sym;
					put(line_sym, keys::stroke, color(17, 235, 60+(i*60), 0xA0));
					put(line_sym, keys::stroke_width, 10);
					r.append(std::move(line_sym));
				}
				appelation_style[i].add_rule(std::move(r));
			}
			m.insert_style(appelation[i] + "_contour", std::move(appelation_style[i]));
		}

		// Provinces (polyline)
		feature_type_style communeline_style;
		{
			rule r;
			//r.set_filter(parse_expression(commune_irouleguy + " or " + commune_bearne));
			{
				line_symbolizer line_sym;
				put(line_sym, keys::stroke, color(0, 0, 0, 0x20));
				put(line_sym, keys::stroke_width, 1);
				dash_array dash;
				dash.emplace_back(8, 4);
				dash.emplace_back(2, 2);
				dash.emplace_back(2, 2);
				put(line_sym, keys::stroke_dasharray, dash);
				r.append(std::move(line_sym));
			}
			communeline_style.add_rule(std::move(r));
		}
		m.insert_style("communelines", std::move(communeline_style));

		//     layers
		for (int i = 0; i < 4; i++)
		{
			parameters p;
			p["type"]="postgis";
			p["host"]="postgres";
			p["port"]="5432";
			p["dbname"]="owm";
			p["user"]="owmuser";
			p["password"]="toor";
			p["table"]=appelation[i];

			layer lyr("Provinces");
			lyr.set_datasource(datasource_cache::instance().create(p));
			lyr.add_style(appelation[i]);
			lyr.add_style(appelation[i] + "_contour");
			lyr.add_style("communelines");
			lyr.set_srs(srs_layers);

			m.add_layer(lyr);
		}

		m.zoom_all();

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

        std::cout << m.scale() << std::endl;
        std::cout << m.scale_denominator() << std::endl;
        save_map(m, "/home/owmuser/src/openstreetmap-carto/aquitaine.xml");
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
