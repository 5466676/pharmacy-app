import 'package:flutter/material.dart';

/// Every icon used in Doaya, in one place so the set can be swapped for a
/// custom line-icon font later without touching screens.
///
/// Directional icons use the Material variants that mirror automatically in
/// RTL: [forward] points left and [back] points right in Arabic layouts.
abstract final class DoayaIcons {
  static const forward = Icons.arrow_forward_rounded;
  static const back = Icons.arrow_back_ios_new_rounded;
  static const menu = Icons.menu_rounded;
  static const search = Icons.search_rounded;
  static const filter = Icons.tune_rounded;
  static const bag = Icons.shopping_bag_outlined;
  static const home = Icons.home_rounded;
  static const homeOutlined = Icons.home_outlined;
  static const chat = Icons.chat_bubble_outline_rounded;
  static const chatFilled = Icons.chat_bubble_rounded;
  static const clock = Icons.schedule_rounded;
  static const person = Icons.person_outline_rounded;
  static const personFilled = Icons.person_rounded;
  static const heart = Icons.favorite_border_rounded;
  static const heartFilled = Icons.favorite_rounded;
  static const share = Icons.ios_share_rounded;
  static const send = Icons.arrow_forward_rounded;
  static const medicine = Icons.medication_outlined;
  static const health = Icons.favorite_border_rounded;
  static const care = Icons.spa_outlined;
  static const baby = Icons.child_care_rounded;
  static const device = Icons.monitor_heart_outlined;
  static const warning = Icons.warning_amber_rounded;
  static const danger = Icons.error_outline_rounded;
  static const check = Icons.check_rounded;
  static const pharmacy = Icons.local_pharmacy_outlined;
  static const dashboard = Icons.space_dashboard_outlined;
  static const inventory = Icons.inventory_2_outlined;
  static const category = Icons.category_outlined;
  static const pos = Icons.point_of_sale_rounded;
  static const debts = Icons.account_balance_wallet_outlined;
  static const cases = Icons.assignment_outlined;
  static const reports = Icons.bar_chart_rounded;
  static const settings = Icons.settings_outlined;
  static const sales = Icons.trending_up_rounded;
  static const expiry = Icons.event_busy_outlined;
  static const sync = Icons.sync_rounded;
  static const barcode = Icons.qr_code_scanner_rounded;
  static const add = Icons.add_rounded;
  static const remove = Icons.remove_rounded;
  static const delete = Icons.delete_outline_rounded;
  static const edit = Icons.edit_outlined;
  static const more = Icons.more_horiz_rounded;
  static const switchUser = Icons.switch_account_outlined;
  static const backspace = Icons.backspace_outlined;
  static const receive = Icons.move_to_inbox_outlined;
  static const adjust = Icons.fact_check_outlined;
  static const customer = Icons.person_add_alt_1_outlined;
  static const payment = Icons.payments_outlined;
  static const cash = Icons.money_rounded;
  static const close = Icons.close_rounded;
  static const swap = Icons.swap_horiz_rounded;
  static const demo = Icons.science_outlined;
  static const staff = Icons.people_outline_rounded;
  static const returns = Icons.undo_rounded;
}
