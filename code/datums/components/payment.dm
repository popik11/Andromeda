
/**
 * Handles simple payment operations where the cost of the object in question doesn't change.
 *
 * What this is useful for:
 * Basic forms of vending.
 * Objects that can drain the owner's money linearly.
 * What this is not useful for:
 * Things where the seller may want to fluxuate the price of the object.
 * Improving standardizing every form of payment handing, as some custom handling is specific to that object.
 **/
/datum/component/payment
	dupe_mode = COMPONENT_DUPE_UNIQUE ///NO OVERRIDING TO CHEESE BOUNTIES
	///Standardized of operation.
	var/cost = 10
	///Flavor style for handling cash (Friendly? Hostile? etc.)
	var/transaction_style = "Clinical"
	///Who's getting paid?
	var/datum/bank_account/target_acc
	///Does this payment component respect same-department-discount?
	var/department_discount = FALSE

/datum/component/payment/Initialize(_cost, _target, _style)
	target_acc = _target
	if(!target_acc)
		target_acc = SSeconomy.get_dep_account(ACCOUNT_CIV)
	cost = _cost
	transaction_style = _style

/datum/component/payment/RegisterWithParent()
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE, PROC_REF(attempt_charge))
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE, PROC_REF(change_cost))

/datum/component/payment/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_OBJ_ATTEMPT_CHARGE, COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE))

/datum/component/payment/proc/attempt_charge(datum/source, atom/movable/target, extra_fees = 0)
	SIGNAL_HANDLER
	if(!cost && !extra_fees) //In case a free variant of anything is made it'll skip charging anyone.
		return
	var/total_cost = cost + extra_fees
	if(!ismob(target))
		return COMPONENT_OBJ_CANCEL_CHARGE
	var/mob/living/user = target
	if(HAS_SILICON_ACCESS(user) || isdrone(user)) //They have evolved beyond the need for mere credits
		return
	var/obj/item/card/id/card
	if(istype(user))
		card = user.get_idcard(TRUE)
	if(!card && istype(user.pulling, /obj/item/card/id))
		card = user.pulling
	if(handle_card(user, card, total_cost))
		return //Only breaks here if the card can handle the cost of purchasing with someone's ID.
	if(handle_cardless(user, total_cost)) //Here we attempt to handle the purchase physically, with held money first. Otherwise we default to below.
		return
	return COMPONENT_OBJ_CANCEL_CHARGE

/**
 * Proc that changes the base cost of the interaction.
 *
 * * source: Datum source of the thing changing the cost.
 * * new_cost: the int value of the attempted new_cost to replace the cost value.
 */
/datum/component/payment/proc/change_cost(datum/source, new_cost)
	SIGNAL_HANDLER

	if(!isnum(new_cost))
		CRASH("change_cost called with variable new_cost as not a number.")
	cost = new_cost

/**
 * Attempts to charge the mob, user, an integer number of credits, total_cost, without the use of an ID card to directly draw upon.
 */
/datum/component/payment/proc/handle_cardless(mob/living/user, total_cost)
	//Here is all the possible non-ID payment methods.
	var/list/counted_money = list()
	var/physical_cash_total = 0
	for(var/obj/item/credit in typecache_filter_list(user.get_all_contents(), GLOB.allowed_money)) //Coins, cash, and credits.
		if(physical_cash_total > total_cost)
			break
		physical_cash_total += credit.get_item_credit_value()
		counted_money += credit

	if(is_type_in_typecache(user.pulling, GLOB.allowed_money) && (physical_cash_total < total_cost)) //Coins(Pulled).
		var/obj/item/counted_credit = user.pulling
		physical_cash_total += counted_credit.get_item_credit_value()
		counted_money += counted_credit

	if(physical_cash_total < total_cost)
		var/armless //Suggestions for those with no arms/simple animals.
		if(!ishuman(user) && !isslime(user))
			armless = TRUE
		else
			var/mob/living/carbon/human/harmless_armless = user
			if(!harmless_armless.get_bodypart(BODY_ZONE_L_ARM) && !harmless_armless.get_bodypart(BODY_ZONE_R_ARM))
				armless = TRUE

		if(armless)
			if(!user.pulling || !iscash(user.pulling) && !istype(user.pulling, /obj/item/card/id))
				to_chat(user, span_notice("Попробуй провести ID-карту, космоденьги, голочип или монету, используя [parent]!"))
				return FALSE
		return FALSE

	if(physical_cash_total < total_cost)
		to_chat(user, span_notice("Недостаточно средств. Отмена."))
		return FALSE
	for(var/obj/cash_object in counted_money)
		qdel(cash_object)
	physical_cash_total -= total_cost

	if(physical_cash_total > 0)
		var/obj/item/holochip/holochange = new /obj/item/holochip(user.loc, physical_cash_total) //Change is made in holocredits exclusively.
		holochange.name = "[holochange.credits] кредитный голочип"
		if(ishuman(user))
			var/mob/living/carbon/human/paying_customer = user
			var/successfully_put_in_hands
			ASYNC //Put_in_hands can sleep, we don't want that to block this proc.
				successfully_put_in_hands = paying_customer.put_in_hands(holochange)
			if(!successfully_put_in_hands)
				user.pulling = holochange
		else
			user.pulling = holochange
	log_econ("[total_cost] кредитов было потрачено на [parent] пользователем [user].")
	to_chat(user, span_notice("Покупка совершена с использованием кредитов."))
	playsound(user, 'sound/effects/cashregister.ogg', 20, TRUE)
	return TRUE

/**
 * Attempts to charge a mob, user, an integer number of credits, total_cost, directly from an ID card/bank account.
 */
/datum/component/payment/proc/handle_card(mob/living/user, obj/item/card/id/idcard, total_cost)
	var/atom/movable/atom_parent = parent

	if(!idcard)
		if(transaction_style == PAYMENT_VENDING)
			to_chat(user, span_warning("Карта не обнаружена."))
		return FALSE
	if(!idcard?.registered_account)
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("На вашей ID-карте не обнаружен аккаунт, как загадочно!"))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("ТЫ ЧТО, ШУТИШЬ? НА ТВОЕЙ ID НЕТ БАНКОВСКОГО СЧЕТА, ИДИОТ."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID-карта не имеет банковского счета. Продолжение."))
			if(PAYMENT_VENDING)
				to_chat(user, span_warning("Аккаунт не найден."))

		return FALSE

	if(!idcard.can_be_used_in_payment(user))
		atom_parent.say("Корпоративные счета заблокированы для личных расходов из-за случаев хищения.")
		return FALSE

	if(!(idcard.registered_account.has_money(total_cost)))
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("Мне очень жаль... Похоже, у вас недостаточно средств."))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("ТЫ ДЕБИЛ. ТЫ ПОЛНЫЙ НЕУДАЧНИК. НЕВЫНОСИМЫЙ БОЛВАН. ТЫ НИЩИЙ."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("На ID-карте недостаточно средств. Отмена."))
			if(PAYMENT_VENDING)
				to_chat(user, span_warning("У вас недостаточно средств для покупки."))
		atom_parent.balloon_alert(user, "требуется [total_cost] кредитов!")
		return FALSE
	target_acc.transfer_money(idcard.registered_account, total_cost, "Nanotrasen: Использование корпоративного оборудования")
	log_econ("[total_cost] кредитов было потрачено на [parent] пользователем [user] через карту [idcard.registered_account.account_holder].")
	idcard.registered_account.bank_card_talk("[total_cost] кредитов списано с вашего счета.")
	playsound(src, 'sound/effects/cashregister.ogg', 20, TRUE)
	SSeconomy.add_audit_entry(idcard.registered_account, total_cost, parent)
	return TRUE

/**
 * Attempts to remove the payment component, currently when the crew wins a revolution.
 * * datum/source: source of the signal.
 */
/datum/component/payment/proc/clean_up(datum/source)
	SIGNAL_HANDLER
	target_acc = null
	qdel(src)
