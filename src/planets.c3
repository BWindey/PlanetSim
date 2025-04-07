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

macro bool is_completely_offscreen(
	Planet* planet, float width, float height, float scaling, float[<2>] origin
) {
	float[<2>] screen_translation = { width / 2, height / 2 };
	float[<2>] pos = (planet.position - origin) * scaling + screen_translation;

	bool planet_offscreen =
		pos.x < -width / 2
		|| pos.x > width * 1.5
		|| pos.y < -height / 2
		|| pos.y > height * 1.5;

	float[<2>] midtrail = (planet.trail[128] - origin) * scaling + screen_translation;
	bool midtrail_offscreen =
		midtrail.x < -width / 2
		|| midtrail.x > width * 1.5
		|| midtrail.y < -height / 2
		|| midtrail.y > height * 1.5;

	float[<2>] endtrail = (planet.trail[255] - origin) * scaling + screen_translation;
	bool endtrail_offscreen =
		endtrail.x < -width / 2
		|| midtrail.x > width * 1.5
		|| midtrail.y < -height / 2
		|| midtrail.y > height * 1.5;

	return planet_offscreen && midtrail_offscreen && endtrail_offscreen;
}

macro draw_planet(Planet* planet, float scaling, float[<2>] origin) {
	float[<2>] translated_pos @noinit;
	float[<2>] p1 @noinit;
	float[<2>] p2 @noinit;

	float screen_width = rl::getScreenWidth();
	float screen_height = rl::getScreenHeight();
	float[<2>] screen_translation = { screen_width / 2, screen_height / 2 };

	if (is_completely_offscreen(planet, screen_width, screen_height, scaling, origin)) {
		return;
	}

	if (planet.drawTrail) {
		char trS = planet.trailStart;
		char idx1 @noinit;
		char idx2 @noinit;
		Color trailColor = planet.color;

		// Draw first line from planet to trail[trailStart]
		p1 = (planet.position - origin) * scaling;
		p2 = (planet.trail[trS] - origin) * scaling;

		p1 += screen_translation;
		p2 += screen_translation;

		rl::drawLineV(p1.to_rl(), p2.to_rl(), trailColor);

		// Draw lines between all trail points
		for(ushort t = 1; t < 256; t++) {
			trailColor.a--;

			idx1 = trS - (char) (t-1);
			idx2 = trS - (char) t;

			p1 = (planet.trail[idx1] - origin) * scaling;
			p2 = (planet.trail[idx2] - origin) * scaling;

			p1 += screen_translation;
			p2 += screen_translation;

			rl::drawLineV(p1.to_rl(), p2.to_rl(), trailColor);
		}
	}
	translated_pos = (planet.position - origin) * scaling;
	translated_pos += screen_translation;

	rl::drawCircleV(
		translated_pos.to_rl(),
		get_entity_radius(planet, scaling),
		planet.color
	);
}

macro float[<2>] get_gravity_vector(Planet p1, Planet p2, float gravity_constant) {
	float[<2>] d = p2.position - p1.position;
	float distance_square = math::max(d.x * d.x + d.y * d.y, 1e-8f);
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
			planets[i].velocity += acceleration / SIMULATED_FPS;

			// Update for planet[j]
			acceleration = -gravity_force / planets[j].mass;
			planets[j].velocity += acceleration / SIMULATED_FPS;
		}
		planets[i].trailStart++;
		planets[i].trail[planets[i].trailStart] = planets[i].position;
		planets[i].position += planets[i].velocity / SIMULATED_FPS;
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

