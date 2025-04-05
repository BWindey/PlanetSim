module gravity_sim;
import raylib5::rl;
import std::math;
import std::io;

const int SCREEN_WIDTH = 1600;
const int SCREEN_HEIGHT = 1000;

const float GRAVITY_CONSTANT = 9.8;

struct Planet {
	uint mass;
	Vector2 position;
	Vector2 velocity;
	Color color;
	Vector2[256] trail;
	char trailStart;
}

macro get_entity_radius(Planet* planet) {
	return 2 * (float) math::min(planet.mass, 10u);
}

macro @addVec2(Vector2 #vec1, Vector2 vec2) {
	#vec1.x += vec2.x;
	#vec1.y += vec2.y;
}

macro draw_planet(Planet* planet) {
	Vector2 translated_pos = planet.position;
	@addVec2(translated_pos, {
		(float) rl::getScreenWidth() / 2,
		(float) rl::getScreenHeight() / 2
	});
	rl::drawCircleV(translated_pos, get_entity_radius(planet), planet.color);
	for(char t = planet.trailStart; t != planet.trailStart - 1; t++) {
		translated_pos = planet.trail[t];
		@addVec2(translated_pos, {
			(float) rl::getScreenWidth() / 2,
			(float) rl::getScreenHeight() / 2
		});
		rl::drawCircleV(translated_pos, 1, planet.color);
	}
}

macro Vector2 get_gravity_vector(Planet p1, Planet p2) {
	float dx = p2.position.x - p1.position.x;
	float dy = p2.position.y - p1.position.y;
	float distance_square = dx * dx + dy * dy;
	float distance = math::sqrt(distance_square);

	float gravity_scalar = GRAVITY_CONSTANT * p1.mass * p2.mass / distance_square;

	return {
		.x = dx * gravity_scalar / distance,
		.y = dy * gravity_scalar / distance
	};
}

fn void update_planets(Planet[] planets) {
	for (uint i = 0; i < planets.len; i++) {
		for (uint j = i + 1; j < planets.len; j++) {
			Vector2 acceleration = get_gravity_vector(planets[i], planets[j]);
			@addVec2(planets[i].velocity, acceleration);
			acceleration.x = -acceleration.x;
			acceleration.y = -acceleration.y;
			@addVec2(planets[j].velocity, acceleration);
		}
		planets[i].trailStart++;
		planets[i].trail[planets[i].trailStart] = planets[i].position;
		@addVec2(planets[i].position, planets[i].velocity);
	}
}

fn int main()
{
	rl::initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "C3 raylib");
	rl::setTargetFPS(30);

	Planet planet1 = {
		.mass = 100,
		.position = {-180, 0},
		.velocity = {2, -1},
		.color = rl::GOLD,
	};
	Planet planet2 = {
		.mass = 10,
		.position = {0, 0},
		.velocity = {0, 4},
		.color = rl::PINK,
	};
	Planet planet3 = {
		.mass = 10,
		.position = {180, 0},
		.velocity = {-2, 1},
		.color = rl::GREEN,
	};

	Planet[*] all_planets = { planet1, planet2, planet3 };

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
