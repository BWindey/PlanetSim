module gravity_sim;
import raylib5::rl;
import std::math;
import std::io;

const int SCREEN_WIDTH = 1600;
const int SCREEN_HEIGHT = 1000;


macro @addVec2(Vector2 #vec1, Vector2 vec2) {
	#vec1.x += vec2.x;
	#vec1.y += vec2.y;
}

fn int main()
{
	rl::initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Gravity simulation");
	rl::setTargetFPS(30);

	Planet[*] all_planets = {{
			.mass = 3000,
			.position = {0, 0},
			.velocity = {0, 0},
			.color = rl::GOLD,
		}, {
			.mass = 1,
			.position = {350, 0},
			.velocity = {0, 10},
			.color = rl::PINK,
			.drawTrail = true,
		},
	};

	while(!rl::windowShouldClose()) {
		rl::clearBackground(rl::BLACK);

		update_planets(&all_planets);

		// -- Drawing --
		rl::beginDrawing();

		rl::drawFPS(0, 0);

		foreach(&planet: all_planets) {
			draw_planet(planet);
		}

		rl::endDrawing();
	}

	rl::closeWindow();

	return 0;
}
