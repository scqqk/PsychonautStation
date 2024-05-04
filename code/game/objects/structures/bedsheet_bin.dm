/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/bedsheets.dmi'
	lefthand_file = 'icons/mob/inhands/items/bedsheet_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/bedsheet_righthand.dmi'
	icon_state = "sheetwhite"
	inhand_icon_state = "sheetwhite"
	slot_flags = ITEM_SLOT_NECK
	layer = BELOW_MOB_LAYER
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	dying_key = DYE_REGISTRY_BEDSHEET
	interaction_flags_click = NEED_DEXTERITY|ALLOW_RESTING

	dog_fashion = /datum/dog_fashion/head/ghost
	/// Custom nouns to act as the subject of dreams
	var/list/dream_messages = list("white")
	/// Cutting it up will yield this.
	var/stack_type = /obj/item/stack/sheet/cloth
	/// The number of sheets dropped by this bedsheet when cut
	var/stack_amount = 3
	/// Denotes if the bedsheet is a single, double, or other kind of bedsheet
	var/bedsheet_type = BEDSHEET_SINGLE
	var/datum/weakref/signal_sleeper //this is our goldylocks

/obj/item/bedsheet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator)
	AddElement(/datum/element/bed_tuckable, mapload, 0, 0, 0)
	if(bedsheet_type == BEDSHEET_DOUBLE)
		stack_amount *= 2
		dying_key = DYE_REGISTRY_DOUBLE_BEDSHEET
	register_context()
	register_item_context()

/obj/item/bedsheet/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(istype(held_item) && (held_item.tool_behaviour == TOOL_WIRECUTTER || held_item.get_sharpness()))
		context[SCREENTIP_CONTEXT_LMB] = "Shred into cloth"

	context[SCREENTIP_CONTEXT_ALT_LMB] = "Rotate"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/bedsheet/add_item_context(datum/source, list/context, mob/living/target)
	if(isliving(target) && target.body_position == LYING_DOWN)
		context[SCREENTIP_CONTEXT_RMB] = "Cover"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/bedsheet/attack_secondary(mob/living/target, mob/living/user, params)
	if(!user.CanReach(target))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(target.body_position != LYING_DOWN)
		return ..()
	if(!user.dropItemToGround(src))
		return ..()

	forceMove(get_turf(target))
	balloon_alert(user, "covered")
	coverup(target)
	add_fingerprint(user)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/bedsheet/attack_self(mob/living/user)
	if(!user.CanReach(src)) //No telekinetic grabbing.
		return
	if(user.body_position != LYING_DOWN)
		return
	if(!user.dropItemToGround(src))
		return

	coverup(user)
	add_fingerprint(user)

/obj/item/bedsheet/proc/coverup(mob/living/sleeper)
	layer = ABOVE_MOB_LAYER
	pixel_x = 0
	pixel_y = 0
	balloon_alert(sleeper, "covered")
	var/angle = sleeper.lying_prev
	dir = angle2dir(angle + 180) // 180 flips it to be the same direction as the mob

	signal_sleeper = WEAKREF(sleeper)
	RegisterSignal(src, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	RegisterSignal(sleeper, COMSIG_MOVABLE_MOVED, PROC_REF(smooth_sheets))
	RegisterSignal(sleeper, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(smooth_sheets))
	RegisterSignal(sleeper, COMSIG_QDELETING, PROC_REF(smooth_sheets))

/obj/item/bedsheet/proc/smooth_sheets(mob/living/sleeper)
	SIGNAL_HANDLER

	UnregisterSignal(src, COMSIG_ITEM_PICKUP)
	UnregisterSignal(sleeper, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(sleeper, COMSIG_LIVING_SET_BODY_POSITION)
	UnregisterSignal(sleeper, COMSIG_QDELETING)
	balloon_alert(sleeper, "smoothed sheets")
	layer = initial(layer)
	SET_PLANE_IMPLICIT(src, initial(plane))
	signal_sleeper = null

// We need to do this in case someone picks up a bedsheet while a mob is covered up
// otherwise the bedsheet will disappear while in our hands if the sleeper signals get activated by moving
/obj/item/bedsheet/proc/on_pickup(datum/source, mob/grabber)
	SIGNAL_HANDLER

	var/mob/living/sleeper = signal_sleeper?.resolve()

	UnregisterSignal(src, COMSIG_ITEM_PICKUP)
	UnregisterSignal(sleeper, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(sleeper, COMSIG_LIVING_SET_BODY_POSITION)
	UnregisterSignal(sleeper, COMSIG_QDELETING)
	signal_sleeper = null

/obj/item/bedsheet/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.get_sharpness())
		if (!(flags_1 & HOLOGRAM_1))
			var/obj/item/stack/shreds = new stack_type(get_turf(src), stack_amount)
			if(!QDELETED(shreds)) //stacks merged
				transfer_fingerprints_to(shreds)
				shreds.add_fingerprint(user)
		qdel(src)
		to_chat(user, span_notice("You tear [src] up."))
	else
		return ..()

/obj/item/bedsheet/click_alt(mob/living/user)
	dir = REVERSE_DIR(dir)
	return CLICK_ACTION_SUCCESS

/obj/item/bedsheet/blue
	icon_state = "sheetblue"
	inhand_icon_state = "sheetblue"
	dream_messages = list("mavi")

/obj/item/bedsheet/green
	icon_state = "sheetgreen"
	inhand_icon_state = "sheetgreen"
	dream_messages = list("yeşil")

/obj/item/bedsheet/grey
	icon_state = "sheetgrey"
	inhand_icon_state = "sheetgrey"
	dream_messages = list("gri")

/obj/item/bedsheet/orange
	icon_state = "sheetorange"
	inhand_icon_state = "sheetorange"
	dream_messages = list("turuncu")

/obj/item/bedsheet/purple
	icon_state = "sheetpurple"
	inhand_icon_state = "sheetpurple"
	dream_messages = list("mor")

/obj/item/bedsheet/patriot
	name = "patriotic bedsheet"
	desc = "You've never felt more free than when sleeping on this."
	icon_state = "sheetUSA"
	inhand_icon_state = "sheetUSA"
	dream_messages = list("Amerika", "özgürlük", "kartal")

/obj/item/bedsheet/rainbow
	name = "rainbow bedsheet"
	desc = "A multicolored blanket. It's actually several different sheets cut up and sewn together."
	icon_state = "sheetrainbow"
	inhand_icon_state = "sheetrainbow"
	dream_messages = list("kırmızı", "turuncu", "sarı", "yeşil", "mavi", "mor", "bir gökkuşağı")

/obj/item/bedsheet/red
	icon_state = "sheetred"
	inhand_icon_state = "sheetred"
	dream_messages = list("kırmızı")

/obj/item/bedsheet/yellow
	icon_state = "sheetyellow"
	inhand_icon_state = "sheetyellow"
	dream_messages = list("sarı")

/obj/item/bedsheet/mime
	name = "mime's blanket"
	desc = "A very soothing striped blanket.  All the noise just seems to fade out when you're under the covers in this."
	icon_state = "sheetmime"
	inhand_icon_state = "sheetmime"
	dream_messages = list("sessizlik", "soğuk bir yüz", "açık bir ağaz", "mime'ı")

/obj/item/bedsheet/clown
	name = "clown's blanket"
	desc = "A rainbow blanket with a clown mask woven in. It smells faintly of bananas."
	icon_state = "sheetclown"
	inhand_icon_state = "sheetrainbow"
	dream_messages = list("honk", "kahkaha", "bir şaka", "gülümseyen bir surat", "clown'ı")

/obj/item/bedsheet/captain
	name = "captain's bedsheet"
	desc = "It has a Nanotrasen symbol on it, and was woven with a revolutionary new kind of thread guaranteed to have 0.01% permeability for most non-chemical substances, popular among most modern captains."
	icon_state = "sheetcaptain"
	inhand_icon_state = "sheetcaptain"
	dream_messages = list("otoriteyi", "altın bir ID", "güneş gözlüğü", "yeşil bir disk", "antik bir silah", "kaptan'ı")

/obj/item/bedsheet/rd
	name = "research director's bedsheet"
	desc = "It appears to have a beaker emblem, and is made out of fire-resistant material, although it probably won't protect you in the event of fires you're familiar with every day."
	icon_state = "sheetrd"
	inhand_icon_state = "sheetrd"
	dream_messages = list("otoriteyi", "gümüş bir ID", "bir bomba", "bir mech", "manyak bir gülümseme", "research director'ü")

// for Free Golems.
/obj/item/bedsheet/rd/royal_cape
	name = "Royal Cape of the Liberator"
	desc = "Majestic."
	dream_messages = list("maden", "taş", "bir golem", "özgürlük")

/obj/item/bedsheet/medical
	name = "medical blanket"
	desc = "It's a 'sterilized' blanket commonly used in the Medbay."
	icon_state = "sheetmedical"
	inhand_icon_state = "sheetmedical"
	dream_messages = list("yaşam enerjisi", "hayat", "ameliyat", "bir doktor")

/obj/item/bedsheet/cmo
	name = "chief medical officer's bedsheet"
	desc = "It's a sterilized blanket that has a cross emblem. There's some cat fur on it, likely from Runtime."
	icon_state = "sheetcmo"
	inhand_icon_state = "sheetcmo"
	dream_messages = list("otoriteyi", "gümüş bir ID", "yaşam enerjisi", "hayat", "ameliyat", "bir kedi", "chief medical officer'i")

/obj/item/bedsheet/hos
	name = "head of security's bedsheet"
	desc = "It is decorated with a shield emblem. While crime doesn't sleep, you do, but you are still THE LAW!"
	icon_state = "sheethos"
	inhand_icon_state = "sheethos"
	dream_messages = list("otoriteyi", "gümüş bir ID", "kelepçeleri", "bir baton", "güneş gözlüklerini", "head of security'i")

/obj/item/bedsheet/hop
	name = "head of personnel's bedsheet"
	desc = "It is decorated with a key emblem. For those rare moments when you can rest and cuddle with Ian without someone screaming for you over the radio."
	icon_state = "sheethop"
	inhand_icon_state = "sheethop"
	dream_messages = list("otoriteyi", "gümüş bir ID", "yükümlülük", "bir bilgisayar", "bir ID", "bir köpek", "head of personnel'i")

/obj/item/bedsheet/ce
	name = "chief engineer's bedsheet"
	desc = "It is decorated with a wrench emblem. It's highly reflective and stain resistant, so you don't need to worry about ruining it with oil."
	icon_state = "sheetce"
	inhand_icon_state = "sheetce"
	dream_messages = list("otoriteyi", "gümüş bir ID", "süper maddeyi", "elektrik eşyalarını", "bir APC", "bir papağan", "chief engineer'i")

/obj/item/bedsheet/qm
	name = "quartermaster's bedsheet"
	desc = "It is decorated with a crate emblem in silver lining.  It's rather tough, and just the thing to lie on after a hard day of pushing paper."
	icon_state = "sheetqm"
	inhand_icon_state = "sheetqm"
	dream_messages = list("otoriteyi", "gümüş bir ID", "bir shuttle", "bir sandık", "quartermaster'ı")

/obj/item/bedsheet/chaplain
	name = "chaplain's blanket"
	desc = "A blanket woven with the hearts of gods themselves... Wait, that's just linen."
	icon_state = "sheetchap"
	inhand_icon_state = "sheetchap"
	dream_messages = list("gri bir ID", "yaratıcıyı", "okunan bir dua", "sokulmak için hazılanmış bir pamuk", "chaplain'i")

/obj/item/bedsheet/brown
	icon_state = "sheetbrown"
	inhand_icon_state = "sheetbrown"
	dream_messages = list("kahverengi")

/obj/item/bedsheet/black
	icon_state = "sheetblack"
	inhand_icon_state = "sheetblack"
	dream_messages = list("siyah")

/obj/item/bedsheet/centcom
	name = "\improper CentCom bedsheet"
	desc = "Woven with advanced nanothread for warmth as well as being very decorated, essential for all officials."
	icon_state = "sheetcentcom"
	inhand_icon_state = "sheetcentcom"
	dream_messages = list("farklı bir ID", "otoriteyi", "sonu")

/obj/item/bedsheet/syndie
	name = "syndicate bedsheet"
	desc = "It has a syndicate emblem and it has an aura of evil."
	icon_state = "sheetsyndie"
	inhand_icon_state = "sheetsyndie"
	dream_messages = list("yeşil bir disk", "kırmızı bir kristal", "parıldayan bir kılıç", "kırmızı bir ID")

/obj/item/bedsheet/cult
	name = "cultist's bedsheet"
	desc = "You might dream of Nar'Sie if you sleep with this. It seems rather tattered and glows of an eldritch presence."
	icon_state = "sheetcult"
	inhand_icon_state = "sheetcult"
	dream_messages = list("bir yapı", "süzülen bir kristal", "parlayan bir kılıç", "kanlı bir sembol", "devasa insansı bir figür")

/obj/item/bedsheet/wiz
	name = "wizard's bedsheet"
	desc = "A special fabric enchanted with magic so you can have an enchanted night. It even glows!"
	icon_state = "sheetwiz"
	inhand_icon_state = "sheetwiz"
	dream_messages = list("bir kitap", "bir patlama", "yıldırım", "bir asa", "bir iskelet", "sihir")

/obj/item/bedsheet/rev
	name = "revolutionary's bedsheet"
	desc = "A bedsheet stolen from a Central Command official's bedroom, used a symbol of triumph against Nanotrasen's tyranny. The golden emblem on the front has been scribbled out."
	icon_state = "sheetrev"
	inhand_icon_state = "sheetrev"
	dream_messages = list(
		"halkı",
		"özgürlüğü",
		"dayanışmayı",
		"uçan kafaları",
		"sopaları",
		"göz alıcı bir ışık",
		"silah arkadaşlarını"
	)

/obj/item/bedsheet/nanotrasen
	name = "\improper Nanotrasen bedsheet"
	desc = "It has the Nanotrasen logo on it and has an aura of duty."
	icon_state = "sheetNT"
	inhand_icon_state = "sheetNT"
	dream_messages = list("otoriteyi", "bir sonu")

/obj/item/bedsheet/ian
	icon_state = "sheetian"
	inhand_icon_state = "sheetian"
	dream_messages = list("bir köpek", "bir tilki")

/obj/item/bedsheet/runtime
	icon_state = "sheetruntime"
	inhand_icon_state = "sheetruntime"
	dream_messages = list("a kitty", "a cat", "meow", "purr", "nya~")

/obj/item/bedsheet/pirate
	name = "pirate's bedsheet"
	desc = "It has a Jolly Roger emblem on it and has a faint scent of grog."
	icon_state = "sheetpirate"
	inhand_icon_state = "sheetpirate"
	dream_messages = list(
		"a buried treasure",
		"an island",
		"a monkey",
		"a parrot",
		"a swashbuckler",
		"a talking skull",
		"avast",
		"being a pirate",
		"'cause a pirate is free",
		"doing whatever you want",
		"gold",
		"landlubbers",
		"stealing",
		"sailing the Seven Seas",
		"yarr",
	)

/obj/item/bedsheet/gondola
	name = "gondola bedsheet"
	desc = "A precious bedsheet made from the hide of a endangered and peculiar critter."
	icon_state = "sheetgondola"
	inhand_icon_state = "sheetgondola"
	dream_messages = list("peace", "comfiness", "a rare critter", "a harmless creature")
	stack_type = /obj/item/stack/sheet/animalhide/gondola
	stack_amount = 1
	///one of four icon states that represent its mouth
	var/gondola_mouth
	///one of four icon states that represent its eyes
	var/gondola_eyes

/obj/item/bedsheet/gondola/Initialize(mapload)
	. = ..()
	gondola_mouth = "sheetgondola_mouth[rand(1, 4)]"
	gondola_eyes = "sheetgondola_eyes[rand(1, 4)]"
	add_overlay(gondola_mouth)
	add_overlay(gondola_eyes)

/obj/item/bedsheet/gondola/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += mutable_appearance(icon_file, gondola_mouth)
		. += mutable_appearance(icon_file, gondola_eyes)

/obj/item/bedsheet/cosmos
	name = "cosmic space bedsheet"
	desc = "Made from the dreams of those who wonder at the stars."
	icon_state = "sheetcosmos"
	inhand_icon_state = "sheetcosmos"
	dream_messages = list("sınırsız Evren'i", "Hans Zimmer müziğini", "uzaylar arasında bir yolculuk", "galaksiyi")
	light_power = 2
	light_range = 1.4

/obj/item/bedsheet/double
	icon_state = "double_sheetwhite"
	worn_icon_state = "sheetwhite"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/blue/double
	icon_state = "double_sheetblue"
	worn_icon_state = "sheetblue"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/green/double
	icon_state = "double_sheetgreen"
	worn_icon_state = "sheetgreen"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/grey/double
	icon_state = "double_sheetgrey"
	worn_icon_state = "sheetgrey"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/orange/double
	icon_state = "double_sheetorange"
	worn_icon_state = "sheetorange"
	dying_key = DYE_REGISTRY_DOUBLE_BEDSHEET
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/purple/double
	icon_state = "double_sheetpurple"
	worn_icon_state = "sheetpurple"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/patriot/double
	icon_state = "double_sheetUSA"
	worn_icon_state = "sheetUSA"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/rainbow/double
	icon_state = "double_sheetrainbow"
	worn_icon_state = "sheetrainbow"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/red/double
	icon_state = "double_sheetred"
	worn_icon_state = "sheetred"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/yellow/double
	icon_state = "double_sheetyellow"
	worn_icon_state = "sheetyellow"
	dying_key = DYE_REGISTRY_DOUBLE_BEDSHEET
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/mime/double
	icon_state = "double_sheetmime"
	worn_icon_state = "sheetmime"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/clown/double
	icon_state = "double_sheetclown"
	worn_icon_state = "sheetclown"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/captain/double
	icon_state = "double_sheetcaptain"
	worn_icon_state = "sheetcaptain"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/rd/double
	icon_state = "double_sheetrd"
	worn_icon_state = "sheetrd"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/medical/double
	icon_state = "double_sheetmedical"
	worn_icon_state = "sheetmedical"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/cmo/double
	icon_state = "double_sheetcmo"
	worn_icon_state = "sheetcmo"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/hos/double
	icon_state = "double_sheethos"
	worn_icon_state = "sheethos"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/hop/double
	icon_state = "double_sheethop"
	worn_icon_state = "sheethop"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/ce/double
	icon_state = "double_sheetce"
	worn_icon_state = "sheetce"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/qm/double
	icon_state = "double_sheetqm"
	worn_icon_state = "sheetqm"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/chaplain/double
	icon_state = "double_sheetchap"
	worn_icon_state = "sheetchap"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/brown/double
	icon_state = "double_sheetbrown"
	worn_icon_state = "sheetbrown"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/black/double
	icon_state = "double_sheetblack"
	worn_icon_state = "sheetblack"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/centcom/double
	icon_state = "double_sheetcentcom"
	worn_icon_state = "sheetcentcom"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/syndie/double
	icon_state = "double_sheetsyndie"
	worn_icon_state = "sheetsyndie"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/cult/double
	icon_state = "double_sheetcult"
	worn_icon_state = "sheetcult"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/wiz/double
	icon_state = "double_sheetwiz"
	worn_icon_state = "sheetwiz"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/rev/double
	icon_state = "double_sheetrev"
	worn_icon_state = "sheetrev"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/nanotrasen/double
	icon_state = "double_sheetNT"
	worn_icon_state = "sheetNT"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/ian/double
	icon_state = "double_sheetian"
	worn_icon_state = "sheetian"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/runtime/double
	icon_state = "double_sheetruntime"
	worn_icon_state = "sheetruntime"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/item/bedsheet/cosmos/double
	icon_state = "double_sheetcosmos"
	worn_icon_state = "sheetcosmos"
	bedsheet_type = BEDSHEET_DOUBLE

/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	anchored = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 70
	/// The number of bedsheets in the bin
	var/amount = 10
	/// A list of actual sheets within the bin
	var/list/sheets = list()
	/// The object hiddin within the bedsheet bin
	var/obj/item/hidden = null

/obj/structure/bedsheetbin/empty
	amount = 0
	icon_state = "linenbin-empty"
	anchored = FALSE


/obj/structure/bedsheetbin/examine(mob/user)
	. = ..()
	if(amount < 1)
		. += "There are no bed sheets in the bin."
	else if(amount == 1)
		. += "There is one bed sheet in the bin."
	else
		. += "There are [amount] bed sheets in the bin."


/obj/structure/bedsheetbin/update_icon_state()
	switch(amount)
		if(0)
			icon_state = "linenbin-empty"
		if(1 to 5)
			icon_state = "linenbin-half"
		else
			icon_state = "linenbin-full"
	return ..()

/obj/structure/bedsheetbin/fire_act(exposed_temperature, exposed_volume)
	if(amount)
		amount = 0
		update_appearance()
	..()

/obj/structure/bedsheetbin/screwdriver_act(mob/living/user, obj/item/tool)
	if(amount)
		to_chat(user, span_warning("The [src] must be empty first!"))
		return ITEM_INTERACT_SUCCESS
	if(tool.use_tool(src, user, 0.5 SECONDS, volume=50))
		to_chat(user, span_notice("You disassemble the [src]."))
		new /obj/item/stack/rods(loc, 2)
		qdel(src)
		return ITEM_INTERACT_SUCCESS

/obj/structure/bedsheetbin/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 0.5 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/structure/bedsheetbin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/bedsheet))
		if(!user.transferItemToLoc(I, src))
			return
		sheets.Add(I)
		amount++
		to_chat(user, span_notice("You put [I] in [src]."))
		update_appearance()

	else if(amount && !hidden && I.w_class < WEIGHT_CLASS_BULKY) //make sure there's sheets to hide it among, make sure nothing else is hidden in there.
		if(!user.transferItemToLoc(I, src))
			to_chat(user, span_warning("\The [I] is stuck to your hand, you cannot hide it among the sheets!"))
			return
		hidden = I
		to_chat(user, span_notice("You hide [I] among the sheets."))


/obj/structure/bedsheetbin/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/bedsheetbin/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	if(amount >= 1)
		amount--

		var/obj/item/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/bedsheet(loc)

		B.forceMove(drop_location())
		user.put_in_hands(B)
		to_chat(user, span_notice("You take [B] out of [src]."))
		update_appearance()

		if(hidden)
			hidden.forceMove(drop_location())
			to_chat(user, span_notice("[hidden] falls out of [B]!"))
			hidden = null

	add_fingerprint(user)


/obj/structure/bedsheetbin/attack_tk(mob/user)
	if(amount >= 1)
		amount--

		var/obj/item/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/bedsheet(loc)

		B.forceMove(drop_location())
		to_chat(user, span_notice("You telekinetically remove [B] from [src]."))
		update_appearance()

		if(hidden)
			hidden.forceMove(drop_location())
			hidden = null

	add_fingerprint(user)
	return COMPONENT_CANCEL_ATTACK_CHAIN
