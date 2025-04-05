module gravity_sim;
import raylib5::rl;
import std::math;
import std::io;

const float GRAVITY_CONSTANT = 9.8;

struct Planet {
	uint mass;
	Vector2 position;
	Vector2 velocity;
	Color color;
	Vector2[256] trail;
	char trailStart;
	bool drawTrail;
}

macro uint get_entity_radius(Planet* planet, scaling) {
	return 2 * math::max((uint) (planet.mass * scaling / 600), 4u);
}

macro draw_planet(Planet* planet, float scaling) {
	Vector2 translated_pos @noinit;

	if (planet.drawTrail) {
		char trS = planet.trailStart;
		char idx @noinit;
		Color trailColor = planet.color;

		for(ushort t = 0; t < 256; t++) {
			idx = trS - (char) t;
			translated_pos = planet.trail[idx];

			translated_pos.x *= scaling;
			translated_pos.y *= scaling;

			@addVec2(translated_pos, {
				(float) rl::getScreenWidth() / 2,
				(float) rl::getScreenHeight() / 2
			});
			rl::drawCircleV(translated_pos, 2, trailColor);
			trailColor.a--;
		}
	}
	translated_pos = planet.position;

	translated_pos.x *= scaling;
	translated_pos.y *= scaling;

	@addVec2(translated_pos, {
		(float) rl::getScreenWidth() / 2,
		(float) rl::getScreenHeight() / 2
	});

	rl::drawCircleV(translated_pos, get_entity_radius(planet, scaling), planet.color);
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
			Vector2 gravity_force = get_gravity_vector(planets[i], planets[j]);
			Vector2 acceleration = {
				.x = gravity_force.x / planets[i].mass,
				.y = gravity_force.y / planets[i].mass,
			};
			@addVec2(planets[i].velocity, acceleration);

			// Update for planet[j]
			acceleration.x = -gravity_force.x / planets[j].mass;
			acceleration.y = -gravity_force.y / planets[j].mass;

			@addVec2(planets[j].velocity, acceleration);
		}
		planets[i].trailStart++;
		planets[i].trail[planets[i].trailStart] = planets[i].position;
		@addVec2(planets[i].position, planets[i].velocity);
	}
}

