class_name AnimSlide extends SceneSlide

## uses animations defined by SlideAnimation Nodes in children to animate the slide

var anim_steps: int = 0
var current_anim_step: int = -1

var fade_tween: Tween = null
var fade_tweens: Array[Tween] = []
var animations: Array[SlideAnimation]

func _ready() -> void:
	super()
	animations = collect_anims_in_children(self, 0)
	animations.sort_custom(compare_by_sort_order)
	anim_steps = animations.size()
	reset()
	
func reset() -> void:
	for tween: Tween in fade_tweens:
		tween.kill()
		
	fade_tweens.clear()
		
	for element: SlideAnimation in animations:
		if !is_instance_valid(element):
			push_warning("found invalid slide animation reference in ", self.name)
		element.reset()
		
	current_anim_step = -1
	
func show_full() -> void:
	for animation: SlideAnimation in animations:
		animation.skip_to_finish()

	current_anim_step = anim_steps

func continue_slide() -> bool:
	current_anim_step += 1
	
	if is_finished(): 
		return true
		
	if current_anim_step > 0:
		animations[current_anim_step-1].skip_to_finish()
	
	animations[current_anim_step].animate()

	return false
	
func set_progress(relative_progress: float) -> bool:
	var requested_step: int = get_anim_index_by_progress(anim_steps, relative_progress)
	
	if requested_step == current_anim_step:
		return is_finished()
		
	if requested_step == current_anim_step + 1:
		return continue_slide()

	if requested_step < 0:
		reset()
		return false
	elif requested_step >= anim_steps:
		show_full()
		return true
		
	for animation_index: int in anim_steps:
		if animation_index < requested_step:
			animations[animation_index].skip_to_finish()
			continue
		
		if animation_index > requested_step:
			animations[animation_index].reset()
			continue

	if current_anim_step < requested_step:
		animations[requested_step].animate()
	else:
		animations[requested_step].skip_to_finish()
	
	if is_finished(): 
		return true
	
	current_anim_step = requested_step
	return false

func is_finished() -> bool:
	return current_anim_step >= anim_steps
			
func is_at_start() -> bool:
	return current_anim_step == 0
	
static func compare_by_sort_order(a: SlideAnimation, b: SlideAnimation) -> int:
	if a.sort_order != b.sort_order:
		return a.sort_order < b.sort_order
		
	return a.tree_index < b.tree_index
	
static func collect_anims_in_children(node: Node, current_index: int) -> Array[SlideAnimation]:
	var res: Array[SlideAnimation] = []
	if node is SlideAnimation:
		res.append(node as SlideAnimation)
		(node as SlideAnimation).tree_index = current_index
		current_index += 1
		
	for child: Node in node.get_children():
		var children_nodes: Array[SlideAnimation]= collect_anims_in_children(child, current_index)
		res.append_array(children_nodes)
		if res.size() > 0:
			current_index = res[res.size()-1].tree_index + 1
	return res

static func get_anim_index_by_progress(given_anim_steps: int, progress: float) -> int:
	return roundi(float(given_anim_steps) * progress)-1
