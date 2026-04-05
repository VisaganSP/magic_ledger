import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../widgets/neo_button.dart';
import '../../../widgets/neo_card.dart';
import '../../../widgets/neo_input.dart';
import '../controllers/category_controller.dart';

class AddCategoryView extends StatefulWidget {
  const AddCategoryView({super.key});

  @override
  State<AddCategoryView> createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final CategoryController categoryController = Get.find();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emojiSearchController = TextEditingController();

  String _selectedIcon = '📁';
  Color _selectedColor = NeoBrutalismTheme.accentPink;
  String _activeEmojiSection = 'Smileys';
  bool _isEditMode = false;
  CategoryModel? _editingCategory;

  // ─── MASSIVE EMOJI LIBRARY ─────────────────────────────────

  static const Map<String, List<String>> _emojiSections = {
    'Smileys': [
      '😀','😃','😄','😁','😆','😅','🤣','😂','🙂','😊',
      '😇','🥰','😍','🤩','😘','😋','😛','😜','🤪','😎',
      '🤓','🧐','🤔','🤫','🤭','🤥','😌','😴','🥱','😷',
      '🤒','🤕','🤮','🥴','😵','🤯','🥳','🥸','😈','👿',
      '💀','☠️','👻','👽','🤖','💩','😺','😸','😹','😻',
    ],
    'People': [
      '👶','🧒','👦','👧','🧑','👱','👨','👩','🧔','👴',
      '👵','🙍','🙎','🙅','🙆','💁','🙋','🧏','🙇','🤦',
      '🤷','👮','🕵️','💂','🥷','👷','🤴','👸','👳','👲',
      '🧕','🤵','👰','🤰','🫄','🤱','👼','🎅','🤶','🦸',
      '🦹','🧙','🧚','🧛','🧜','🧝','🧞','🧟','🧌','💆',
    ],
    'Hands': [
      '👋','🤚','🖐️','✋','🖖','🫱','🫲','🫳','🫴','👌',
      '🤌','🤏','✌️','🤞','🫰','🤟','🤘','🤙','👈','👉',
      '👆','🖕','👇','☝️','🫵','👍','👎','✊','👊','🤛',
      '🤜','👏','🙌','🫶','👐','🤲','🤝','🙏','✍️','💅',
      '🤳','💪','🦾','🦿','🦵','🦶','👂','🦻','👃','🧠',
    ],
    'Food': [
      '🍏','🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐',
      '🍈','🍒','🍑','🥭','🍍','🥥','🥝','🍅','🍆','🥑',
      '🫛','🥦','🥬','🥒','🌶️','🫑','🌽','🥕','🫒','🧄',
      '🧅','🥔','🍠','🫘','🥐','🍞','🥖','🥨','🧀','🥚',
      '🍳','🧈','🥞','🧇','🥓','🥩','🍗','🍖','🌭','🍔',
      '🍟','🍕','🫓','🥪','🥙','🧆','🌮','🌯','🫔','🥗',
      '🥘','🫕','🥫','🍝','🍜','🍲','🍛','🍣','🍱','🥟',
      '🦪','🍤','🍙','🍚','🍘','🍥','🥠','🥮','🍢','🍡',
      '🍧','🍨','🍦','🥧','🧁','🍰','🎂','🍮','🍭','🍬',
      '🍫','🍿','🍩','🍪','🌰','🥜','🍯','🥛','🍼','🫗',
      '☕','🍵','🧃','🥤','🧋','🍶','🍺','🍻','🥂','🍷',
      '🥃','🍸','🍹','🧉','🍾','🧊','🥄','🍴','🍽️','🥣',
    ],
    'Animals': [
      '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐻‍❄️','🐨',
      '🐯','🦁','🐮','🐷','🐸','🐵','🙈','🙉','🙊','🐒',
      '🐔','🐧','🐦','🐤','🐣','🐥','🦆','🦅','🦉','🦇',
      '🐺','🐗','🐴','🦄','🐝','🪱','🐛','🦋','🐌','🐞',
      '🐜','🪰','🪲','🪳','🦟','🦗','🕷️','🕸️','🦂','🐢',
      '🐍','🦎','🦖','🦕','🐙','🦑','🦐','🦞','🦀','🐡',
      '🐠','🐟','🐬','🐳','🐋','🦈','🦭','🐊','🐅','🐆',
      '🦓','🦍','🦧','🐘','🦣','🦛','🦏','🐪','🐫','🦒',
    ],
    'Nature': [
      '🌵','🎄','🌲','🌳','🌴','🪵','🌱','🌿','☘️','🍀',
      '🎍','🪴','🎋','🍃','🍂','🍁','🪺','🪹','🍄','🌾',
      '💐','🌷','🌹','🥀','🌺','🌸','🌼','🌻','🌞','🌝',
      '🌛','🌜','🌚','🌕','🌖','🌗','🌘','🌑','🌒','🌓',
      '🌔','🌙','🌎','🌍','🌏','🪐','💫','⭐','🌟','✨',
      '⚡','☄️','💥','🔥','🌪️','🌈','☀️','🌤️','⛅','🌥️',
      '☁️','🌦️','🌧️','⛈️','🌩️','🌨️','❄️','☃️','⛄','🌬️',
      '💨','💧','💦','🫧','☔','☂️','🌊','🌫️',
    ],
    'Travel': [
      '🚗','🚕','🚙','🚌','🚎','🏎️','🚓','🚑','🚒','🚐',
      '🛻','🚚','🚛','🚜','🛵','🏍️','🛺','🚲','🛴','🛹',
      '🛼','🚏','🛣️','🛤️','🛞','⛽','🚨','🚥','🚦','🛑',
      '🚧','⚓','🛟','⛵','🛶','🚤','🛳️','⛴️','🛥️','🚢',
      '✈️','🛩️','🛫','🛬','🪂','💺','🚁','🚟','🚠','🚡',
      '🛰️','🚀','🛸','🗽','🗼','🏰','🏯','🏟️','🎡','🎢',
      '🎠','⛲','⛱️','🏖️','🏝️','🏜️','🌋','⛰️','🏔️','🗻',
      '🏕️','⛺','🛖','🏠','🏡','🏢','🏣','🏤','🏥','🏦',
    ],
    'Activities': [
      '⚽','🏀','🏈','⚾','🥎','🎾','🏐','🏉','🥏','🎱',
      '🪀','🏓','🏸','🏒','🏑','🥍','🏏','🪃','🥅','⛳',
      '🪁','🛝','🏹','🎣','🤿','🥊','🥋','🎽','🛹','🛼',
      '🛷','⛸️','🥌','🎿','⛷️','🏂','🪂','🏋️','🤼','🤸',
      '⛹️','🤺','🤾','🏌️','🏇','🧘','🏄','🏊','🤽','🚣',
      '🧗','🚵','🚴','🏆','🥇','🥈','🥉','🏅','🎖️','🏵️',
      '🎗️','🎫','🎟️','🎪','🎭','🎨','🎬','🎤','🎧','🎼',
      '🎹','🥁','🪘','🎷','🎺','🪗','🎸','🪕','🎻','🎲',
    ],
    'Objects': [
      '⌚','📱','📲','💻','⌨️','🖥️','🖨️','🖱️','🖲️','🕹️',
      '🗜️','💽','💾','💿','📀','📼','📷','📸','📹','🎥',
      '📽️','🎞️','📞','☎️','📟','📠','📺','📻','🎙️','🎚️',
      '🎛️','🧭','⏱️','⏲️','⏰','🕰️','⌛','⏳','📡','🔋',
      '🪫','🔌','💡','🔦','🕯️','🪔','🧯','🛢️','💸','💵',
      '💴','💶','💷','🪙','💰','💳','💎','⚖️','🪜','🧰',
      '🪛','🔧','🔨','⚒️','🛠️','⛏️','🪚','🔩','⚙️','🪤',
      '🧱','⛓️','🧲','🔫','💣','🧨','🪓','🔪','🗡️','⚔️',
      '📦','📫','📬','📭','📮','🗳️','✏️','✒️','🖋️','🖊️',
      '🖌️','🖍️','📝','💼','📁','📂','🗂️','📅','📆','🗒️',
      '📇','📈','📉','📊','📋','📌','📍','📎','🖇️','📏',
      '📐','✂️','🗃️','🗄️','🗑️','🔒','🔓','🔏','🔐','🔑',
    ],
    'Symbols': [
      '❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔',
      '❤️‍🔥','❤️‍🩹','💕','💞','💓','💗','💖','💘','💝','❣️',
      '💟','☮️','✝️','☪️','🕉️','☸️','✡️','🔯','🕎','☯️',
      '♈','♉','♊','♋','♌','♍','♎','♏','♐','♑',
      '♒','♓','⛎','🔀','🔁','🔂','▶️','⏩','⏭️','⏯️',
      '⏪','⏮️','🔼','⏫','🔽','⏬','⏸️','⏹️','⏺️','⏏️',
      '✅','☑️','✔️','❌','❎','➕','➖','➗','✖️','♾️',
      '⁉️','❓','❔','❕','❗','〰️','💱','💲','⚕️','♻️',
      '⚜️','🔱','📛','🔰','⭕','✅','❌','❓','❕','❗',
    ],
    'Flags': [
      '🏁','🚩','🎌','🏴','🏳️','🏳️‍🌈','🏳️‍⚧️','🏴‍☠️',
      '🇮🇳','🇺🇸','🇬🇧','🇯🇵','🇰🇷','🇨🇳','🇫🇷','🇩🇪',
      '🇮🇹','🇪🇸','🇧🇷','🇷🇺','🇦🇺','🇨🇦','🇲🇽','🇸🇬',
      '🇦🇪','🇸🇦','🇿🇦','🇳🇬','🇪🇬','🇰🇪','🇹🇷','🇹🇭',
    ],
  };

  static const List<Color> _allColors = [
    Color(0xFFFDB5D6), Color(0xFFFFB49A), Color(0xFFB8E994), Color(0xFF9DB4FF),
    Color(0xFFFDD663), Color(0xFFE8CCFF), Color(0xFFBFE3F0), Color(0xFFD4E4D1),
    Color(0xFFF5E6D3), Color(0xFFDCC9E8), Color(0xFFA7C7E7), Color(0xFFFFDAB9),
    Color(0xFF4DB6AC), Color(0xFFE57373), Color(0xFFC8B593), Color(0xFFB0BEC5),
    Color(0xFFFF8A80), Color(0xFFFF80AB), Color(0xFFEA80FC), Color(0xFFB388FF),
    Color(0xFF8C9EFF), Color(0xFF82B1FF), Color(0xFF80D8FF), Color(0xFF84FFFF),
    Color(0xFFA7FFEB), Color(0xFFB9F6CA), Color(0xFFCCFF90), Color(0xFFF4FF81),
    Color(0xFFFFFF8D), Color(0xFFFFE57F), Color(0xFFFFD180), Color(0xFFFF9E80),
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.teal, Colors.green,
    Colors.amber, Colors.orange, Colors.deepOrange, Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() { setState(() {}); });
    _initData();
  }

  void _initData() {
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args['isEdit'] == true) {
      _isEditMode = true;
      _editingCategory = args['category'] as CategoryModel;
      setState(() {
        _nameController.text = _editingCategory!.name;
        _selectedIcon = _editingCategory!.icon;
        _selectedColor = _editingCategory!.colorValue;
        if (_editingCategory!.budget != null) {
          _budgetController.text = _editingCategory!.budget.toString();
        }
        if (_editingCategory!.description != null) {
          _descriptionController.text = _editingCategory!.description!;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    _emojiSearchController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final category = CategoryModel(
      id: _isEditMode ? _editingCategory!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor.value,
      budget: _budgetController.text.isNotEmpty ? double.tryParse(_budgetController.text) : null,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      isDefault: _isEditMode ? _editingCategory!.isDefault : false,
    );

    if (_isEditMode) {
      categoryController.updateCategory(category);
      Navigator.of(Get.context!).pop();
      Get.snackbar('Updated', 'Category updated!',
          backgroundColor: NeoBrutalismTheme.accentBlue,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
    } else {
      categoryController.addCategory(category);
      Navigator.of(Get.context!).pop();
      Get.snackbar('Created', 'Category added!',
          backgroundColor: NeoBrutalismTheme.accentGreen,
          colorText: NeoBrutalismTheme.primaryBlack,
          borderWidth: 3, borderColor: NeoBrutalismTheme.primaryBlack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeoBrutalismTheme.darkBackground : NeoBrutalismTheme.primaryWhite,
      appBar: AppBar(
        title: Text(_isEditMode ? 'EDIT CATEGORY' : 'ADD CATEGORY',
            style: const TextStyle(fontWeight: FontWeight.w900, color: NeoBrutalismTheme.primaryBlack)),
        backgroundColor: NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentGreen, isDark),
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          // Live preview
          _buildPreview(isDark),
          const SizedBox(height: 16),
          _buildNameField(isDark),
          const SizedBox(height: 16),
          _buildEmojiPicker(isDark),
          const SizedBox(height: 16),
          _buildColorPicker(isDark),
          const SizedBox(height: 16),
          _buildBudgetField(isDark),
          const SizedBox(height: 16),
          _buildDescriptionField(isDark),
          const SizedBox(height: 32),
          _buildSaveButton(isDark),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // ─── LIVE PREVIEW ────────────────────────────────────────

  Widget _buildPreview(bool isDark) {
    return Center(child: Container(
      width: 120, height: 120,
      decoration: NeoBrutalismTheme.neoBox(
          color: _selectedColor, borderColor: NeoBrutalismTheme.primaryBlack, offset: 6),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(_selectedIcon, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 6),
        Text(
          _nameController.text.isEmpty ? 'PREVIEW' : _nameController.text.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
              color: NeoBrutalismTheme.primaryBlack),
          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
        ),
      ]),
    ));
  }

  // ─── NAME ────────────────────────────────────────────────

  Widget _buildNameField(bool isDark) {
    return NeoInput(
      controller: _nameController,
      label: 'CATEGORY NAME',
      hint: 'e.g., Groceries',
      isDark: isDark,

      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Enter a name';
        if (v.trim().length < 2) return 'Too short';
        return null;
      },
    );
  }

  // ─── EMOJI PICKER ────────────────────────────────────────

  Widget _buildEmojiPicker(bool isDark) {
    final searchText = _emojiSearchController.text.toLowerCase();
    List<String> displayEmojis;

    if (searchText.isNotEmpty) {
      // Search across all sections
      displayEmojis = _emojiSections.values.expand((e) => e).toList();
      // Simple filter: show all since emoji search by text is limited
    } else {
      displayEmojis = _emojiSections[_activeEmojiSection] ?? [];
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('SELECT ICON', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),

      // Section tabs (horizontal scroll)
      SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _emojiSections.keys.map((section) {
            final isActive = _activeEmojiSection == section;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() { _activeEmojiSection = section; }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? NeoBrutalismTheme.primaryBlack
                        : (isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2),
                  ),
                  child: Text(section, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white
                          : (isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack))),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 10),

      // Emoji grid
      Container(
        height: 220,
        decoration: NeoBrutalismTheme.neoBox(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, crossAxisSpacing: 4, mainAxisSpacing: 4),
          itemCount: displayEmojis.length,
          itemBuilder: (ctx, i) {
            final emoji = displayEmojis[i];
            final isSelected = _selectedIcon == emoji;
            return GestureDetector(
              onTap: () => setState(() { _selectedIcon = emoji; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? NeoBrutalismTheme.getThemedColor(NeoBrutalismTheme.accentYellow, isDark)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: NeoBrutalismTheme.primaryBlack, width: 2)
                      : null,
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ─── COLOR PICKER ────────────────────────────────────────

  Widget _buildColorPicker(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('SELECT COLOR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
          color: isDark ? NeoBrutalismTheme.darkText : NeoBrutalismTheme.primaryBlack)),
      const SizedBox(height: 8),
      Container(
        height: 140,
        decoration: NeoBrutalismTheme.neoBox(
            color: isDark ? NeoBrutalismTheme.darkSurface : NeoBrutalismTheme.primaryWhite,
            borderColor: NeoBrutalismTheme.primaryBlack),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 11, crossAxisSpacing: 6, mainAxisSpacing: 6),
          itemCount: _allColors.length,
          itemBuilder: (ctx, i) {
            final color = _allColors[i];
            final isSelected = _selectedColor.value == color.value;
            return GestureDetector(
              onTap: () => setState(() { _selectedColor = color; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle,
                  border: Border.all(
                      color: isSelected ? NeoBrutalismTheme.primaryBlack : Colors.transparent,
                      width: isSelected ? 3 : 0),
                  boxShadow: isSelected ? [
                    BoxShadow(color: NeoBrutalismTheme.primaryBlack.withOpacity(0.3),
                        offset: const Offset(2, 2)),
                  ] : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: NeoBrutalismTheme.primaryBlack)
                    : null,
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ─── BUDGET ──────────────────────────────────────────────

  Widget _buildBudgetField(bool isDark) {
    return NeoInput(
      controller: _budgetController,
      label: 'MONTHLY BUDGET (OPTIONAL)',
      hint: '0.00',
      isDark: isDark,
      keyboardType: TextInputType.number,
      prefixText: '\u{20B9} ',
      validator: (v) {
        if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Invalid number';
        return null;
      },
    );
  }

  // ─── DESCRIPTION ─────────────────────────────────────────

  Widget _buildDescriptionField(bool isDark) {
    return NeoInput(
      controller: _descriptionController,
      label: 'DESCRIPTION (OPTIONAL)',
      hint: 'What is this category for?',
      maxLines: 3,
      isDark: isDark,
    );
  }

  // ─── SAVE ────────────────────────────────────────────────

  Widget _buildSaveButton(bool isDark) {
    return NeoButton(
      text: _isEditMode ? 'UPDATE CATEGORY' : 'SAVE CATEGORY',
      onPressed: _save,
      color: NeoBrutalismTheme.getThemedColor(
          _isEditMode ? NeoBrutalismTheme.accentBlue : NeoBrutalismTheme.accentGreen, isDark),
      height: 64,
      icon: _isEditMode ? Icons.update : Icons.save,
    );
  }
}