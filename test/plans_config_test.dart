import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_system/config/plans_config.dart';

void main() {
  PlanInfo plan(String name) =>
      PlansConfig.plans.firstWhere((p) => p.name == name);

  List<String> tiers(String name) =>
      plan(name).tiers.map((t) => '${t.users} = ${t.priceUsd}').toList();

  test('plans and headline prices match the Cloudora proposal', () {
    expect(PlansConfig.plans.map((p) => p.name).toList(),
        ['Basic', 'Pro', 'Premium']);
    expect(PlansConfig.plans.map((p) => p.priceUsd).toList(),
        ['\$40', '\$100', '\$350']);
  });

  test('team size prices match the proposal', () {
    expect(tiers('Basic'), ['5 users = \$30', '10 users = \$40']);
    expect(tiers('Pro'), [
      '10–15 users = \$80',
      '15–20 users = \$90',
      '20–25 users = \$100',
    ]);
    expect(tiers('Premium'), [
      '50–60 users = \$330',
      '70–100 users = \$350',
      'Unlimited users = \$375',
    ]);
  });

  test('all prices are whole dollar amounts', () {
    final all = [
      for (final p in PlansConfig.plans) ...[
        p.priceUsd,
        ...p.tiers.map((t) => t.priceUsd),
      ],
    ];
    for (final price in all) {
      expect(price, matches(RegExp(r'^\$\d+$')));
    }
  });

  test('one plan is highlighted and every plan lists features and tiers', () {
    expect(PlansConfig.plans.where((p) => p.recommended).length, 1);
    for (final p in PlansConfig.plans) {
      expect(p.features, isNotEmpty);
      expect(p.tiers, isNotEmpty);
    }
  });

  test('the deployment fee is 20 percent', () {
    expect(PlansConfig.deploymentFeePercent, 20);
  });

  test('plan text never uses the word free', () {
    final text = [
      for (final p in PlansConfig.plans) ...[p.name, p.audience, ...p.features],
      ...PlansConfig.customDeploymentExamples,
    ].join(' ').toLowerCase();
    expect(RegExp(r'\bfree\b').hasMatch(text), isFalse);
  });
}
