import 'package:flutter/material.dart';
import 'brand_palette.dart';

class NavPage extends StatefulWidget {
  final BrandPalette brand;
  const NavPage({super.key, required this.brand});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  late DateTime _selected = DateTime.now();

  DateTime get _weekStart {
    final wd = _selected.weekday; // Mon=1..Sun=7
    return _selected.subtract(Duration(days: wd - 1));
  }

  Future<void> _openCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) {
        final b = widget.brand;
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: b.primary,
              brightness: Brightness.light,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: b.primaryDark),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selected = picked);
  }

  void _gotoBooking() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking page - Coming Soon')));
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.brand;
    final size = MediaQuery.sizeOf(context);
    final isPhone = size.width < 600;

    final start = _weekStart;
    final days = List<DateTime>.generate(
      7,
      (i) => start.add(Duration(days: i)),
    );

    return Scaffold(
      backgroundColor: b.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/avatar.png',
                      width: isPhone ? 88 : 120,
                      height: isPhone ? 116 : 158,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, I'm Lorem.",
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Dolor sit amet, consectetur adipiscing elit. "
                            "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
                            "Read more…",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: b.subtext, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    "Make a Schedule",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _openCalendar,
                    style: TextButton.styleFrom(
                      foregroundColor: b.subtext,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      "${_monthName(_selected.month)} ${_selected.year}",
                      style: TextStyle(color: b.subtext),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 78,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final d = days[index];
                    final isSelected = _isSameDay(d, _selected);
                    return _DayChip(
                      date: d,
                      brand: b,
                      selected: isSelected,
                      onTap: () => setState(() => _selected = d),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: b.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _gotoBooking,
                  child: const Text("Book 30 min. Call"),
                ),
              ),

              const SizedBox(height: 18),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MenuChip(title: "About Me", onTap: () {}, brand: b),
                  _MenuChip(title: "Portfolio", onTap: () {}, brand: b),
                  _MenuChip(title: "Archive", onTap: () {}, brand: b),
                  _MenuChip(title: "Contact", onTap: () {}, brand: b),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[m - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final BrandPalette brand;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({
    required this.date,
    required this.brand,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: selected ? Colors.white : brand.subtext.withOpacity(0.45),
        shape: BoxShape.circle,
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? brand.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: brand.border),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: brand.primary.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _weekday3(date.weekday),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : brand.subtext,
              ),
            ),
            Text(
              "${date.day}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            dot,
          ],
        ),
      ),
    );
  }

  String _weekday3(int wd) {
    const map = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return map[wd]!;
  }
}

class _MenuChip extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final BrandPalette brand;

  const _MenuChip({
    required this.title,
    required this.onTap,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        backgroundColor: brand.card,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(title),
    );
  }
}
