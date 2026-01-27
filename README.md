# TalkieTalkie
<img align="right" width="100" height="100" src="https://github.com/substain/TalkieTalkie/blob/main/icon.svg">
A presentation template/framework to create interactive presentations within Godot.

You can test the example presentation here: [https://substain.itch.io/talkietalkie](https://substain.itch.io/talkietalkie).

## Requirements
* Godot 4.x (*This template was only tested with Godot 4.4+. Using an earlier version should be possible with minor modifications.*)
* A basic understanding of how to use Godot

## Quickstart: How to create a new presentation
The following steps are intended to provide a quick introduction to creating a new presentation with this framework.

1) Create an inherited scene from `engine/base/presentation.tscn`. Using a separate folder for your presentation and its assets may be helpful, e.g. in `content/my_presentation`
2) Create the slides and add them to the tree
	* The fastest way to set up a slide or a template is to use/modify a slide from the examples, e.g. `content/example_base/template/example_*.tscn`
	* You can use the SlideGenerator to quickly create multiple text slides from markdown-like text and a template slide
3) Add your custom background as child of the Background CanvasLayer
4) Edit the exported properties in the Presentation & UI nodes and/or update the input actions according to your preferences

You can have a look at `content/example_base/example_base_presentation.tscn` and/or `content/example_2d/example_2d_presentation.tscn` for examples. 
All files in `content/example*` are mainly used for reference purposes and can safely be deleted, if necessary.

## Keybindings
*These are the default keybindings, they can be configured via Godot's input action map*

* **Continue Slide** (`continue`) - Right Arrow Key / Down Arrow Key / Space / Enter / Mouse Wheel Down / Left Click
* **Previous Slide** (`back`) - Left Arrow Key / Up Arrow Key / Page Up / Mouse Wheel Up
* **Skip Slide** (`skip_slide`) - Page Down / Mouse Wheel Down
* **Show/Hide UI** (`toggle_ui`) - F1 / Tab / Right Click
* **Restore/Center Side Window** (`restore_side_window`) - F11
* **Fullscreen** (`fullscreen`) - F12
* **Quit** (`quit`) - Escape
* **Draw with PaintingPointer 1** (`draw_pointer_1`) - Ctrl (Hold) + any mouse button (Hold)
* **Draw with PaintingPointer 2** (`draw_pointer_2`) - Alt (Hold) + any mouse button (Hold)

* **Movement** for the 2D example (`move_*`) - W, A, S, D

## Components
This section aims to provide a basic documentation of the components.

*Note that this project is currently rather in a prototype status and some functionality may be reworked in the future.*

### Presentation
The Presentation, Presentation2D and Presentation3D nodes are used for a basic setup and act as a glue for UI and the controller. They also contain properties for configuring the overall presentation, such as the default transition between slides. Slides below this nodes receive an index based on their order in the tree (unless a custom order is used).

The presentation nodes usually have a **SlideController** child, which handles the state of the presentation, i.e. changing slides, playing animations, and jumping between slides.

### Slide
A slide is the main building block of a presentation in TalkieTalkie. Currently, only the **AnimSlide** implementation is used in the examples, which seems to cover the basic use cases.
AnimSlides collect all SlideAnimation nodes in its children and start them based on their ordering according to their sortorder (or top-down if no sortorder is provided).

### SlideAnimation
These nodes define how a slide is progressed and how changes within a slide are animated. The `targetNodes` property specifies which nodes are affected by the animation. If this property is empty, the SlideAnimation's parent node will be used as the target for the animation.

### SlideHelper and SlideContext
**SlideHelper** is an autoload used for globally accessing the current state and main components of the presentation. It provides access to the **SlideContext** which holds context-specific information such as the Camera2D in 2D presentations. 

### UI
The UI contains the following components:

* A **Control Bar** used for navigation, starting an automatic slideshow, and shortcuts to fullscreen and closing the presentation

* The **Tab Navigation Bar** are a quick way to see the current progress and navigate between slides. At the moment, this is mainly useful for presentations with fewer slides, because no further grouping of slides or scrolling is done.

* An **Settings** menu that contain language and audio options

Note that if the side window is active, the UI will show up there.

### Side-Window
An optional window showing presentation infos. You can configure the basic behavior of this via the SideWindowBase node, which is part of the presentation. In this window, previews for the last, current, and next slides can be displayed. Also, the side window shows time informations and slide comments as well as the UI, if active.

Note that currently, slide previews are shown by packing them into packed scenes. This may lead to an error with signals on packed scenes inside these slides:

`load_slide_by_packed_scene(): Signal x is already connected to given callable y in that object.`

You can make the packed scene local inside the slide to avoid this error. It also seems like you can safely ignore this error.

The layout of this window (size, position, and preview layouts) is stored in the preferences and loaded on startup.

### PaintingPointer
This Node is currently located within the UI and adds the possibility to highlight specific sections of a slide. Holding a button (Default: Ctrl and Alt) will show an icon, and lets you draw onto the slides. Drawings are removed after some seconds have passed or the slide is changed.
There are some configuration options exposed via `all_paint_properties` on that node.

### SlideGenerator
With the **SlideGenerator**, you can generate slides from markdown-like text. This tool script can be attached to any node, and will generate Slides based on the text provided via the `input_text` property. 
* For each header, marked by "# ", a slide is generated based on the `slide_scene`.
* The `content_scene` will be used for the nodes created for the content (which is everything below the header).
* With `slide_title_path`, you can specify the path in the template scene that represents the title of the slide whereas `slide_content_parent_path` specifies under which node the content scene(s) are placed as children.
* Besides not creating duplicated slides with the same title via `ignore_if_slide_name_exists` you can also choose to `replace_existing_instatiated_slides` (dangerous!)

Hit `Generate Slides` to generate the slides.

## Planned Features
Here is an incomplete list of features you can hope to see in the future:

* A searchable table of contents (UI) that that provides improved slide navigation
* Workflow improvements for creating slides, especially regarding translations
* Better UI Scaling and mobile UX improvements
* A way to theme slides more conveniently
* An example scene for 3D presentations
