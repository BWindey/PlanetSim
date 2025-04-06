module gravity_sim;
import raylib5::rl;
import std::math;
import std::io;

struct Planet {
	uint mass;
	float[<2>] position;
	float[<2>] velocity;
	Color color;
	float[<2>][256] trail;
	char trailStart;
	bool drawTrail;
}

macro uint get_entity_radius(Planet* planet, scaling) {
	return 2 * math::max((uint) (planet.mass * scaling / 600), 4u);
}

macro draw_planet(Planet* planet, float scaling, float[<2>] origin) {
	float[<2>] translated_pos @noinit;

	if (planet.drawTrail) {
		char trS = planet.trailStart;
		char idx @noinit;
		Color trailColor = planet.color;

		for(ushort t = 0; t < 256; t++) {
			idx = trS - (char) t;
			translated_pos = (planet.trail[idx] - origin) * scaling;
			translated_pos.x += (float) rl::getScreenWidth() / 2;
			translated_pos.y += (float) rl::getScreenHeight() / 2;

			rl::drawCircleV(translated_pos.to_rl(), 2, trailColor);
			trailColor.a--;
		}
	}
	translated_pos = (planet.position - origin) * scaling;
	translated_pos.x += (float) rl::getScreenWidth() / 2;
	translated_pos.y += (float) rl::getScreenHeight() / 2;

	rl::drawCircleV(
		translated_pos.to_rl(),
		get_entity_radius(planet, scaling),
		planet.color
	);
}

macro float[<2>] get_gravity_vector(Planet p1, Planet p2, float gravity_constant) {
	float[<2>] d = p2.position - p1.position;
	float distance_square = d.x * d.x + d.y * d.y;
	float distance = math::sqrt(distance_square);

	float gravity_scalar = gravity_constant * p1.mass * p2.mass / distance_square;

	return d * gravity_scalar / distance;
}

fn void update_planets(Configuration config, float[<2>]* origin) {
	Planet[] planets = config.planets;
	float[<2>] gravity_force, acceleration;

	for (uint i = 0; i < planets.len; i++) {
		for (uint j = i + 1; j < planets.len; j++) {
			gravity_force = get_gravity_vector(
				planets[i], planets[j], config.gravity_constant
			);
			acceleration = gravity_force / planets[i].mass;
			planets[i].velocity += acceleration;

			// Update for planet[j]
			acceleration = -gravity_force / planets[j].mass;
			planets[j].velocity += acceleration;
		}
		planets[i].trailStart++;
		planets[i].trail[planets[i].trailStart] = planets[i].position;
		planets[i].position += planets[i].velocity;
	}

	if (config.focus_on_planet) {
		*origin = planets[config.focus_index].position;
	}
}


macro @move_focus(Configuration #config, int num) {
	if (num < 0 || num >= #config.planets.len) {
		return;
	}

	#config.focus_index = num;
}

