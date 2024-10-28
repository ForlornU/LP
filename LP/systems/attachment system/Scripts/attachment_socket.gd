@tool
@icon("res://systems/attachment system/socket.png")
extends Node2D
class_name AttachmentSocket

enum IK_chain_type {CCDIK, FABRIK}
@export var placement_mode : bool = true:
	set(val):
		placement_mode = val
		call_deferred("update_state")
@export var IK_type : IK_chain_type:
	set(val):
		IK_type = val
		call_deferred("update_ik_type")
@export var accepted_type : EntityPart.type

var creature_creator : CreatureCreator

#Occupancy
var occupied : bool = false
var limb : LimbBase
var entity : EntityPart

#Visuals
var socket_icon = preload("res://systems/attachment system/socket.png")
const GREEN_SOCKET_SMALL = preload("res://addons/attachmentgui/Sprites/green_socket_small.png")
const RED_SOCKET_SMALL = preload("res://addons/attachmentgui/Sprites/red_socket_small.png")
const GRAY_SOCKET_SMALL = preload("res://addons/attachmentgui/Sprites/gray_socket_small.png")
const BLUE_SOCKET_SMALL = preload("res://addons/attachmentgui/Sprites/blue_socket_small.png")
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	placement_mode = true #redundancy
	update_state()


func init_cc(cc : CreatureCreator):
	if not creature_creator:
		creature_creator = cc


func assign_new_limb(part : EntityPart):
	if not part or placement_mode or part.entity_type != accepted_type:
		push_error("Cannot assign limb to socket")
		return
	occupied = true
	update_state()
	part.reparent(get_parent())
	entity = part


func remove_limb():
	occupied = false
	entity = null
	update_state()


func find_closest_bone():
	if not creature_creator:
		push_warning("Creature Creator is null in socket!")
		return
	var closest_bone
	var closest_dist = INF
	for entity in creature_creator.entities:
		var dist = global_position.distance_to(entity.global_position)
		if dist < closest_dist:
			closest_bone = entity
			closest_dist = dist
	if closest_bone:
		reparent(closest_bone)


func update_ik_type():
	if not creature_creator:
		return
	creature_creator.update_ik_types()
	

#Gray if placement, red if placed but empty, green if placed and socketed
func update_state():
	if placement_mode:
		sprite_2d.texture = GRAY_SOCKET_SMALL
		return
	find_closest_bone()
	if occupied:
		sprite_2d.texture = BLUE_SOCKET_SMALL
	elif !occupied and get_parent() is not Bone2D:
		sprite_2d.texture = RED_SOCKET_SMALL
	else:
		sprite_2d.texture = GREEN_SOCKET_SMALL
		
