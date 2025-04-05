module gravity_sim;
import raylib5::rl;

struct Configuration {
	float gravity_constant;
	Planet[] planets;
	uint central_planet;
}

Planet[*] planets1 = {
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
	{
		.mass = 10000,
		.position = { 0, 0 },
		.velocity = { 0, 0 },
		.color = rl::RED,
		.drawTrail = true,
	},
};

Configuration config1 = {
	.gravity_constant = 9,
	.planets = &planets1,
	.central_planet = 3,
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
	.planets = &planets2,
	.central_planet = 1,
};
