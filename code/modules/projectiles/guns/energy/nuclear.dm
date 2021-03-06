/obj/item/weapon/gun/energy/gun
	name = "A716 Energy Pistol"
	desc = "A common energy weapon used as security enforcement and personal defense. Comes standard with Stun and Kill settings, and a sleek, black finish."
	icon_state = "energystun100"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'

	charge_cost = 100 //How much energy is needed to fire.
	projectile_type = "/obj/item/projectile/energy/electrode"
	origin_tech = "combat=3;magnets=2"
	modifystate = "energystun"

	var/mode = 0 //0 = stun, 1 = kill


	attack_self(mob/living/user as mob)
		switch(mode)
			if(0)
				mode = 1
				charge_cost = 100
				fire_sound = 'sound/weapons/Laser.ogg'
				user << "\red [src.name] is now set to kill."
				projectile_type = "/obj/item/projectile/beam"
				modifystate = "energykill"
			if(1)
				mode = 0
				charge_cost = 100
				fire_sound = 'sound/weapons/Taser.ogg'
				user << "\red [src.name] is now set to stun."
				projectile_type = "/obj/item/projectile/energy/electrode"
				modifystate = "energystun"
		update_icon()


/obj/item/weapon/gun/energy/gun/captain
	name = "Bolt 2411"
	desc = "A true classic. Powerful and deadly, this chromed energy pistol is as much a fine-tuned personal defense weapon as it is a collector's item. Comes with a polished walnut stock."
	cell_type = "/obj/item/weapon/cell/high"
	icon_state = "capenergystun100"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'

	charge_cost = 50 //How much energy is needed to fire.
	projectile_type = "/obj/item/projectile/energy/hvyelectrode"
	origin_tech = "combat=4;magnets=3"
	modifystate = "capenergystun"
	w_class = 2.0

	attack_self(mob/living/user as mob)
		switch(mode)
			if(0)
				mode = 1
				charge_cost = 100
				fire_sound = 'sound/weapons/Laser.ogg'
				user << "\red [src.name] is now set to kill."
				projectile_type = "/obj/item/projectile/beam"
				modifystate = "capenergykill"
			if(1)
				mode = 0
				charge_cost = 50
				fire_sound = 'sound/weapons/Taser.ogg'
				user << "\red [src.name] is now set to stun."
				projectile_type = "/obj/item/projectile/energy/hvyelectrode"
				modifystate = "capenergystun"
		update_icon()


/obj/item/weapon/gun/energy/gun/nuclear
	name = "R407 Nuclear Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor. Use with extreme caution, as the containment fields inside the weapon are unstable."
	icon_state = "nucgun"
	origin_tech = "combat=3;materials=5;powerstorage=3"
	var/lightfail = 0
	var/charge_tick = 0
	cell_type = "/obj/item/weapon/cell/high"

	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()


	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		if((power_supply.charge / power_supply.maxcharge) != 1)
			if(!failcheck())	return 0
			power_supply.give(100)
			update_icon()
		return 1


	proc
		failcheck()
			lightfail = 0
			if (prob(src.reliability)) return 1 //No failure
			if (prob(src.reliability))
				for (var/mob/living/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
					if (src in M.contents)
						M << "\red Your gun feels pleasantly warm for a moment."
					else
						M << "\red You feel a warm sensation."
					M.apply_effect(rand(3,120), IRRADIATE)
				lightfail = 1
			else
				for (var/mob/living/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
					if (src in M.contents)
						M << "\red Your gun's reactor overloads!"
					M << "\red You feel a wave of heat wash over you."
					M.apply_effect(300, IRRADIATE)
				crit_fail = 1 //break the gun so it stops recharging
				processing_objects.Remove(src)
				update_icon()
			return 0


		update_charge()
			if (crit_fail)
				overlays += "nucgun-whee"
				return
			var/ratio = power_supply.charge / power_supply.maxcharge
			ratio = round(ratio, 0.25) * 100
			overlays += "nucgun-[ratio]"


		update_reactor()
			if(crit_fail)
				overlays += "nucgun-crit"
				return
			if(lightfail)
				overlays += "nucgun-medium"
			else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
				overlays += "nucgun-light"
			else
				overlays += "nucgun-clean"


		update_mode()
			if (mode == 0)
				overlays += "nucgun-stun"
			else if (mode == 1)
				overlays += "nucgun-kill"


	emp_act(severity)
		..()
		reliability -= round(15/severity)


	update_icon()
		overlays.Cut()
		update_charge()
		update_reactor()
		update_mode()
