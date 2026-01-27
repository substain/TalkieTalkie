class_name AnimSlide extends SceneSlide

## uses animations defined by SlideAnimation Nodes in children to animate the slide

var anim_steps: int = 0
var current_anim_step: int = -1

var fade_tween: Tween = null
var fade_tweens: Array[Tween] = []
var animations: Array[SlideAnimation]

var progress_elements: Dictionary[Variant, bool] = {} # Dictionary[Any, bool]

var current_progress: float = 0.0

func _ready() -> void:
	super()
	animations = collect_anims_in_children(self, 0)
	animations.sort_custom(compare_by_sort_order)
	anim_steps = animations.size()
	_prepare_progress_elements()
	reset()
	
func _prepare_progress_elements() -> void:
	for animation: SlideAnimation in animations:
		progress_elements[animation as Variant] = false
	
func reset() -> void:
	for tween: Tween in fade_tweens:
		tween.kill()
		
	fade_tweens.clear()
		
	for animation: SlideAnimation in animations:
		if !is_instance_valid(animation):
			push_warning("found invalid slide animation reference in ", self.name)
		animation.reset()
		progress_elements[animation as Variant] = false
		
	update_anim_step(-1)
	
func show_full() -> void:
	for animation: SlideAnimation in animations:
		animation.skip_to_finish()
		progress_elements[animation as Variant] = true
	update_anim_step(anim_steps)

func continue_slide() -> bool:
	var target_anim_step: int = current_anim_step + 1
	
	if is_finished_by_step(target_anim_step): 
		return true

	if target_anim_step > 0:
		var animation: SlideAnimation = animations[target_anim_step-1]
		animation.skip_to_finish()
		progress_elements[animation as Variant] = true
	
	var current_animation: SlideAnimation = animations[target_anim_step]
	current_animation.animate()
	progress_elements[current_animation as Variant] = true
	update_anim_step(target_anim_step)

	return false
	
func set_progress(relative_progress: float) -> bool:
	var requested_step: int = get_anim_index_by_progress(anim_steps, relative_progress)
	
	if requested_step == current_anim_step:
		return is_finished_by_step(requested_step)
		
	if requested_step == current_anim_step + 1:
		return continue_slide()

	if requested_step < 0:
		reset()
		return false
	elif requested_step >= anim_steps:
		show_full()
		return true
		
	for animation_index: int in anim_steps:
		var anim: SlideAnimation = animations[animation_index]
		if animation_index < requested_step:
			anim.skip_to_finish()
			progress_elements[anim as Variant] = true
			continue
		
		if animation_index > requested_step:
			anim.reset()
			progress_elements[anim as Variant] = false
			continue
			
	var target_anim: SlideAnimation = animations[requested_step]
	if current_anim_step < requested_step:
		target_anim.animate()
	else:
		target_anim.skip_to_finish()
	
	progress_elements[target_anim as Variant] = true
	if is_finished_by_step(requested_step): 
		return true
	
	update_anim_step(requested_step)
	return false

func update_anim_step(new_anim_step: int) -> void:
	current_anim_step = new_anim_step
	_update_progress(get_progress_by_anim_index(anim_steps, current_anim_step))

func get_progress_elements() -> Dictionary[Variant, bool]:
	return progress_elements

func is_finished_by_step(target_anim_step: int) -> bool:
	return target_anim_step >= anim_steps

func is_finished() -> bool:
	return is_finished_by_step(current_anim_step)
			
func is_at_start() -> bool:
	return current_anim_step == -1
		
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

static func get_progress_by_anim_index(given_anim_steps: int, current_index: int) -> float:
	if given_anim_steps == 0:
		return 1.0
	return float(current_index + 1) / given_anim_steps
	
static func get_anim_index_by_progress(given_anim_steps: int, progress: float) -> int:
	return roundi(float(given_anim_steps) * progress)-1
