module gravity_sim;
import raylib5::rl;

struct Configuration {
	float gravity_constant;
	bool focus_on_planet;
	int focus_index;
	Planet[] planets;
}

Planet[*] planets1 = {
	{
		.mass = 10000,
		.position = { 0, 0 },
		.velocity = { 0, 0 },
		.color = rl::RED,
		.drawTrail = true,
	},
	{
		.mass = 4,
		.position = { 0, 200 },
		.velocity = { -25, -4 },
		.color = rl::GREEN,
		.drawTrail = true,
	},
	{
		.mass = 40,
		.position = { 0, -200 },
		.velocity = { 25, 4 },
		.color = rl::BLUE,
		.drawTrail = true,
	},
};

Configuration config1 = {
	.gravity_constant = 9,
	.focus_on_planet = true,
	.focus_index = 0,
	.planets = &planets1,
};

Planet[*] planets2 = {
	{
		.mass = 10000,
		.position = { 0, 0 },
		.velocity = { 0, 0 },
		.color = rl::RED,
		.drawTrail = true,
	},
	{
		.mass = 9,
		.position = { 150, 0 },
		.velocity = { 0, 25 },
		.color = rl::BLUE,
		.drawTrail = true,
	},
	{
		.mass = 29,
		.position = { 340, 0 },
		.velocity = { 0, 17 },
		.color = rl::PURPLE,
		.drawTrail = true,
	},
	{
		.mass = 60,
		.position = { 450, 0 },
		.velocity = { 0, 15 },
		.color = rl::MAGENTA,
		.drawTrail = true,
	},
};

Configuration config2 = {
	.gravity_constant = 8,
	.focus_on_planet = true,
	.focus_index = 0,
	.planets = &planets2,
};

fn Planet[256] generate_planets() {
	Planet[256] planets @noinit;
	int width = SCREEN_WIDTH;
	int height = SCREEN_HEIGHT;

	for (int i = 0; i < 256; i++) {
		planets[i].mass = rl::getRandomValue(5, 100);
		planets[i].position.x = rl::getRandomValue(-width + 20, width - 40);
		planets[i].position.y = rl::getRandomValue(-height + 20, height - 40);
		planets[i].velocity.x = rl::getRandomValue(-20, 20);
		planets[i].velocity.y = rl::getRandomValue(-20, 20);
		planets[i].color = {
			(char) rl::getRandomValue(150, 255),
			(char) rl::getRandomValue(150, 255),
			(char) rl::getRandomValue(150, 255),
			255
		};
		switch (i % 3) {
			case 0:
				planets[i].color.r = 255;
			case 1:
				planets[i].color.g = 255;
			case 2:
				planets[i].color.b = 255;
		}
		planets[i].drawTrail = true;

		for (ushort c = 0; c < 256; c++) {
			planets[i].trail[c] = planets[i].position;
		}
	}

	return planets;
}
