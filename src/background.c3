module gravity_sim;
import raylib5::rl;
import std::math;
import std::io;

const int STAR_COUNT = 2000;
alias Background = Star[STAR_COUNT];

struct Star {
	uint[<2>] position;
	Color color;
}

fn Color generate_star_colour() {
	// Generate colour between red and blue
	int change = rl::getRandomValue(-15, 15) * 5;
	int[<3>] rgb = (int[<3>]) { [0..2] = 255 } - math::abs(change);
	if (change >= 0) {
		rgb.x = 255;
	}
	if (change <= 0) {
		rgb.z = 255;
	}

	// Random brightness
	int brightness = rl::getRandomValue(5, 9) * rl::getRandomValue(5, 10);
	rgb = (rgb * brightness) / 100;

	return { ...((char[<3>]) rgb), 255 };
}

fn Background generate_stars() {
	Star[STAR_COUNT] stars @noinit;
	for (int i = 0; i < STAR_COUNT; i++) {
		// *2 because you can fullscreen
		stars[i].position.x = rl::getRandomValue(0, rl::getScreenWidth() * 2);
		stars[i].position.y = rl::getRandomValue(0, rl::getScreenHeight() * 2);
		stars[i].color = generate_star_colour();
	}

	return stars;
}

fn void draw_background(Background* stars) {
	foreach (&star: stars) {
		if (rl::getRandomValue(0, 20) == 0) {
			star.color.a += (char) rl::getRandomValue(-4, 4);
		}
		rl::drawPixel(...star.position, star.color);
	}
}
