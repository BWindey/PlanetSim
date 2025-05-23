module gravity_sim;
import raylib5::rl;
import std::math;

const int SCREEN_WIDTH = 1600;
const int SCREEN_HEIGHT = 1000;
const int FPS = 30;
const int SIMULATED_FPS = 1;

macro Vector2 float[<2>].to_rl(self) => { ...self  };

macro void @checkAndHandleKeyPress(
	#next_scaling, #current_config, #origin, #f3_menu
) {
	KeyboardKey pressed_key = (KeyboardKey) rl::getKeyPressed();
	if (pressed_key >= rl::KEY_ZERO && pressed_key <= rl::KEY_NINE) {
		pressed_key -= rl::KEY_ZERO;
		@move_focus(#current_config, (int) pressed_key);
	}
	if (rl::isKeyPressed(rl::KEY_EQUAL)) {
		#next_scaling *= 1.1;
		#next_scaling = math::clamp(#next_scaling, 0.001f, 10.0f);
	} else if (rl::isKeyPressed(rl::KEY_MINUS)) {
		#next_scaling *= 0.9;
		#next_scaling = math::clamp(#next_scaling, 0.001f, 10.0f);
	}

	// Toggle watching planets
	if (rl::isKeyPressed(rl::KEY_T)) {
		#current_config.focus_on_planet = !#current_config.focus_on_planet;
	}
	// Reset origin to zero and disable focus
	if (rl::isKeyPressed(rl::KEY_Z)) {
		#current_config.focus_on_planet = false;
		#origin = { 0, 0 };
	}
	// Toggle F3 menu
	if (rl::isKeyPressed(rl::KEY_F3)) {
		#f3_menu = !#f3_menu;
	}
}

fn int main()
{
	rl::initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Gravity simulation");
	rl::setTargetFPS(FPS);

	Configuration current_config = config2;

	float zoom_duration = 1.0f;
	float zoom_speed @noinit;
	float scaling = 1.0;
	float next_scaling = scaling;

	float[<2>] origin;
	bool f3_menu = false;

	Background stars = generate_stars();

	while(!rl::windowShouldClose()) {
		@checkAndHandleKeyPress(next_scaling, current_config, origin, f3_menu);

		zoom_speed = 1.0f - math::pow(0.001f, rl::getFrameTime() / zoom_duration);
		scaling += (next_scaling - scaling) * zoom_speed;
		scaling = math::clamp(scaling, 0.001f, 10.0f);
		if (math::abs(next_scaling - scaling) < 0.001f) {
			scaling = next_scaling;
		}

		update_planets(current_config, &origin);

		// -- Drawing --
		rl::clearBackground(rl::BLACK);
		rl::beginDrawing();

		draw_background(&stars);


		if (f3_menu) {
			rl::drawFPS(0, 0);
			rl::drawText(rl::textFormat("Scaling: %02.05f", scaling), 0, 20, 20, rl::GREEN);
			rl::drawText(rl::textFormat("Origin: {%03.02f, %03.02f}", ...origin), 0, 40, 20, rl::GREEN);
		}

		foreach(&planet: current_config.planets) {
			draw_planet(planet, scaling, origin);
		}

		rl::endDrawing();
	}

	rl::closeWindow();

	return 0;
}
