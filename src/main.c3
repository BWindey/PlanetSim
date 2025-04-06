module gravity_sim;
import raylib5::rl;
import std::math;
import std::io;

const int SCREEN_WIDTH = 1600;
const int SCREEN_HEIGHT = 1000;
const int FPS = 30;

macro @addVec2(Vector2 #vec1, Vector2 vec2) {
	#vec1.x += vec2.x;
	#vec1.y += vec2.y;
}

macro Vector2 float[<2>].to_rl(self) => { ...self  };

fn int main()
{
	rl::initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Gravity simulation");
	rl::setTargetFPS(FPS);

	Configuration current_config = config2;
	float zoom_duration = 1.0f;
	float zoom_speed @noinit;
	float scaling = 1.0;
	float next_scaling = scaling;

	while(!rl::windowShouldClose()) {
		KeyboardKey pressed_key = (KeyboardKey) rl::getKeyPressed();
		if (pressed_key >= rl::KEY_ZERO && pressed_key <= rl::KEY_NINE) {
			pressed_key -= rl::KEY_ZERO;
			bring_back(current_config, (int) pressed_key);
		}
		if (rl::isKeyPressed(rl::KEY_EQUAL)) {
			next_scaling *= 1.1;
			next_scaling = math::clamp(next_scaling, 0.001f, 10.0f);
		} else if (rl::isKeyPressed(rl::KEY_MINUS)) {
			next_scaling *= 0.9;
			next_scaling = math::clamp(next_scaling, 0.001f, 10.0f);
		}

		zoom_speed = 1.0f - math::pow(0.001f, rl::getFrameTime() / zoom_duration);
		scaling += (next_scaling - scaling) * zoom_speed;
		scaling = math::clamp(scaling, 0.001f, 10.0f);
		if (math::abs(next_scaling - scaling) < 0.001f) {
			scaling = next_scaling;
		}

		update_planets(current_config);

		// -- Drawing --
		rl::clearBackground(rl::BLACK);
		rl::beginDrawing();

		rl::drawFPS(0, 0);
		rl::drawText(rl::textFormat("Scaling: %02.05f", scaling), 0, 20, 20, rl::GREEN);

		foreach(&planet: current_config.planets) {
			draw_planet(planet, scaling);
		}

		rl::endDrawing();
	}

	rl::closeWindow();

	return 0;
}
