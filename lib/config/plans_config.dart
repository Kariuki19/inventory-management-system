/// One team-size price point inside a plan.
class PlanTier {
  final String users;
  final String priceUsd;

  const PlanTier(this.users, this.priceUsd);
}

class PlanInfo {
  /// Used by the consultation form and email: Basic, Pro or Premium.
  final String name;

  /// Headline monthly price, as named in Cloudora's pricing proposal.
  final String priceUsd;
  final String audience;
  final List<String> features;

  /// Monthly price by team size.
  final List<PlanTier> tiers;
  final bool recommended;

  const PlanInfo({
    required this.name,
    required this.priceUsd,
    required this.audience,
    required this.features,
    required this.tiers,
    this.recommended = false,
  });
}

/// Source: Cloudora's StockSense pricing and deployment proposal.
class PlansConfig {
  /// One-time deployment fee, as a percentage of the monthly plan.
  static const int deploymentFeePercent = 20;

  static const List<PlanInfo> plans = [
    PlanInfo(
      name: 'Basic',
      priceUsd: '\$40',
      audience: 'Small shops & boutiques',
      features: ['Add and manage items', 'Stock alerts', 'Expiry tracking'],
      tiers: [
        PlanTier('Up to 5 users', '\$30'),
        PlanTier('6–10 users', '\$40'),
      ],
    ),
    PlanInfo(
      name: 'Pro',
      priceUsd: '\$100',
      audience: 'Growing SMEs',
      features: [
        'Everything in Basic',
        'Inventory analytics',
        'Export data reports',
        'AI predictions',
        'POS integration',
      ],
      tiers: [
        PlanTier('10–15 users', '\$80'),
        PlanTier('16–20 users', '\$90'),
        PlanTier('21–25 users', '\$100'),
      ],
      recommended: true,
    ),
    PlanInfo(
      name: 'Premium',
      priceUsd: '\$350',
      audience: 'Retail chains & warehouses',
      features: ['Everything in Pro', 'Multiple locations'],
      tiers: [
        PlanTier('50–60 users', '\$330'),
        PlanTier('70–100 users', '\$350'),
        PlanTier('Unlimited users', '\$375'),
      ],
    ),
  ];

  static const List<String> customDeploymentExamples = [
    'Custom product categories, SKU formats or stock-keeping rules',
    'Integration with your POS, e-commerce platform or ERP',
    'Automated reorder levels for each warehouse',
    'Reporting dashboards and alerts built around your business',
  ];
}
