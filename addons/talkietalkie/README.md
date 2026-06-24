# TalkieTalkie
<img align="right" width="100" height="100" src="https://codeberg.org/substain/TalkieTalkie/raw/branch/main/.github/images/icon.png">
An addon for creating interactive presentations within <a href="https://godotengine.org/" target="_blank">Godot</a>.

Check out the [TalkieTalkie itch page](https://substain.itch.io/talkietalkie) for a live build of the example presentation.

*Disclaimer: To use this addon, you need a basic understanding of Godot, since the presentations are built in the engine and exported as builds. Especially if you want to create more customized slides/presentations, you may need to familiarise yourself with the inner workings of this addon.
In any case, feel free to [open an issue](https://codeberg.org/substain/TalkieTalkie/issues).*

The following sections should provide an introduction / overview on getting started with TalkieTalkie. Further information can be found in the [Wiki](https://codeberg.org/substain/TalkieTalkie/wiki)

## Overview
- [Installation](#installation)
- [Quickstart](#quickstart)
- [Keybindings](#keybindings)
- [Planned Features](#planned-features)
- [License](license)

## Installation
1. **Install the addon** via the [Asset Library](https://godotengine.org/asset-library/asset/4783) / [Asset Store](https://store.godotengine.org/asset/substain/talkietalkie/) (recommended) or manually:
 - Asset Store: with your project opened in Godot, open the `Asset Store` tab, search for TalkieTalkie, **Download** and **Install** 
 _(for Godot versions prior to 4.7, the tab is named `AssetLib`)_
 - manually: download the latest release from Github, unpack it, and copy the `addons/talkietalkie` folder to the `addons` folder in your project.
2. **Enable the addon** via `Project Settings` -> `Plugins`. This will prompt you to restart the Godot Editor (to reload the Input Map)
3. **Update the project settings**:
    - `display/window/subwindows/embed_subwindows` to `false` in case you want to use the side window
    - `display/window/size/viewport_width` and `display/window/size/viewport_height` to match your target slide size. This should be the same size you should set the Presentation node to, later on. For example, the Demo Scenes and the slide templates currently use 1920x1080 and will be cut off if they don't match the viewport size.
    
If you encounter errors during initialization, try reloading the project after enabling the addon.

**Note:** This template is being developed in the latest version of Godot and has been tested with 4.5+. Using a Godot 4.4 is currently possible with some modifications to the SideWindow, earlier versions require further changes to the code base.

You can find the example presentation at `/demo/example_base/talkie_example_base_presentation.tscn` and `/demo/example_2d/talkie_example_2d_presentation.tscn`.
All files in `/demo/example/` are mainly used for reference purposes and can be deleted, if necessary.

## Quickstart
While you can manually create presentations, using the presentation generator is recommended. Even if you do create a presentation manually, feel free to have a look at `talkie_presentation_generator.gd`, as it also serves as a configuration example.

### Via Generator
You can create presentations easily via the presentation generator, which can be found at **Project** -> **Tools** -> **TalkieTalkie: Generate Presentation** (if the plugin is active).
This will prompt you with a popup where you can specify the name, type (Control, 2D or 3D), content, background and theme of the presentation. Most options should be self-explanatory. Everything can be customized after creation, the content generation via markdown can also be done later using the SlideGenerator.

**Note:** Using the 2D or 3D type option currently only have an impact on the layout of the slides. You can have a control type presentation and use a 2D background, if you want to. Also note that 3D presentations have not really been tested so far.

### Manually
The following steps are intended to provide a quick introduction to creating a new presentation with this framework.

1) Create an inherited scene from `/engine/base/talkie_presentation.tscn`. Using a dedicated folder for your presentation and its assets may be helpful.
2) Create the slides and add them to your presentation scene.
	* The fastest way to set up a slide or a template is to use/modify a slide from the examples, e.g. `/demo/example_base/template/talkie_example_*.tscn`
	* You can use the SlideGenerator to quickly create multiple text slides from markdown-like text and a template slide
3) Optional: add a custom background as child of the Background node
4) Optional: Edit the exported properties in the Presentation & UI nodes and/or update the input actions according to your preferences

## Keybindings
*These are the default keybindings that are added when the plugin is activated and can be configured via Godot's input action map.*

* **Continue Slide** (`tt_continue`) - Right Arrow Key / Down Arrow Key / Space / Left Click
* **Previous Slide** (`tt_back`) - Left Arrow Key / Up Arrow Key / Page Up / Mouse Wheel Up
* **Skip Slide** (`tt_skip_slide`) - Page Down / Mouse Wheel Down
* **Show/Hide UI** (`tt_toggle_ui`) - F1 / Tab / Right Click
* **Restore/Center Side Window** (`tt_restore_side_window`) - F11
* **Fullscreen** (`tt_fullscreen`) - F12
* **Quit** (`tt_quit`) - Escape
* **Draw with DrawPointer 1** (`tt_draw_pointer_1`) - Ctrl (Hold) + any mouse button (Hold)
* **Draw with DrawPointer 2** (`tt_draw_pointer_2`) - Alt (Hold) + any mouse button (Hold)

* **Movement** for the 2D example (`tt_move_*`) - W, A, S, D

**Note:** Unhandled left click input events trigger a slide continue as well. You can change this behavior in the TalkieTalkie project settings (`talkietalkie/general/continue_on_unhandled_left_click`).


## Planned Features
Here is an incomplete list of features you can hope to see in the future:

* A searchable table of contents (UI) that that provides improved slide navigation
* A better integration for Game Showcases
* Workflow improvements for creating slides (translations, images, markdown)
* An example scene for 3D presentations
* Theming, UI/UX and mobile improvements

## Screenshots

<p align="center">
	<img height="200px" title="Example Presentation (v0.0.9)" alt="Example Presentation (v0.0.9)" src="https://github.com/user-attachments/assets/ab18c73a-2665-4560-858a-ff7e7bd7e499" />
	<img height="200px" title="Side Window (v0.0.9)" alt="Side Window (v0.0.9)" src="https://github.com/user-attachments/assets/8017d5c8-26da-471f-b288-1ad34bbc670a" />
	<img height="200px" title="Presentation Generator UI (v0.0.9)" alt="Presentation Generator UI (v0.0.9)" src="https://github.com/user-attachments/assets/5215b809-22ed-480b-ba3c-9eec3e2a8636" />
</p>

## License
MIT License (see [LICENSE.md](LICENSE.md))
