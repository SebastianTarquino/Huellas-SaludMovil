import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Country {
  final String name;
  final String flag;
  final String code; // ej "+57"
  final int digits; // ej 10

  const Country({
    required this.name,
    required this.flag,
    required this.code,
    required this.digits,
  });
}

const List<Country> countriesList = [
  Country(name: 'Colombia', flag: '🇨🇴', code: '+57', digits: 10),
  Country(name: 'México', flag: '🇲🇽', code: '+52', digits: 10),
  Country(name: 'Estados Unidos', flag: '🇺🇸', code: '+1', digits: 10),
  Country(name: 'España', flag: '🇪🇸', code: '+34', digits: 9),
  Country(name: 'Argentina', flag: '🇦🇷', code: '+54', digits: 10),
  Country(name: 'Chile', flag: '🇨🇱', code: '+56', digits: 9),
  Country(name: 'Perú', flag: '🇵🇪', code: '+51', digits: 9),
  Country(name: 'Ecuador', flag: '🇪🇨', code: '+593', digits: 9),
  Country(name: 'Venezuela', flag: '🇻🇪', code: '+58', digits: 10),
  Country(name: 'Brasil', flag: '🇧🇷', code: '+55', digits: 11),
  Country(name: 'Panamá', flag: '🇵🇦', code: '+507', digits: 8),
  Country(name: 'Costa Rica', flag: '🇨🇷', code: '+506', digits: 8),
  Country(name: 'Rep. Dominicana', flag: '🇩🇴', code: '+1', digits: 10),
  Country(name: 'Guatemala', flag: '🇬🇹', code: '+502', digits: 8),
  Country(name: 'Honduras', flag: '🇭🇳', code: '+504', digits: 8),
  Country(name: 'El Salvador', flag: '🇸🇻', code: '+503', digits: 8),
  Country(name: 'Nicaragua', flag: '🇳🇮', code: '+505', digits: 8),
  Country(name: 'Bolivia', flag: '🇧🇴', code: '+591', digits: 8),
  Country(name: 'Paraguay', flag: '🇵🇾', code: '+595', digits: 9),
  Country(name: 'Uruguay', flag: '🇺🇾', code: '+598', digits: 8),
];

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const PhoneInputField({
    Key? key,
    required this.controller,
    this.labelText = 'Teléfono de contacto',
    this.enabled = true,
    this.onChanged,
  }) : super(key: key);

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  Country _selectedCountry = countriesList[0]; // Colombia por defecto

  @override
  void initState() {
    super.initState();
    // Extraer prefijo si ya viene en el controller
    final text = widget.controller.text.trim();
    if (text.startsWith('+')) {
      for (final c in countriesList) {
        if (text.startsWith(c.code)) {
          _selectedCountry = c;
          widget.controller.text = text.replaceFirst(c.code, '').trim();
          break;
        }
      }
    }
  }

  void _showCountryPicker() {
    if (!widget.enabled) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = countriesList.where((c) {
              final query = searchQuery.toLowerCase();
              return c.name.toLowerCase().contains(query) ||
                  c.code.contains(query);
            }).toList();

            return Container(
              padding: const EdgeInsets.all(16),
              height: 450,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    "Seleccionar País",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Buscar país o prefijo...",
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        final isSelected = c.code == _selectedCountry.code && c.name == _selectedCountry.name;
                        return ListTile(
                          leading: Text(c.flag, style: const TextStyle(fontSize: 26)),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Text(
                            "${c.code} (${c.digits} dig)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.purple : Colors.grey[700],
                            ),
                          ),
                          tileColor: isSelected ? Colors.purple.withOpacity(0.08) : null,
                          onTap: () {
                            setState(() {
                              _selectedCountry = c;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Retorna el teléfono completo con prefijo para guardar en backend
  String get fullPhoneNumber {
    final num = widget.controller.text.trim();
    if (num.isEmpty) return '';
    return "${_selectedCountry.code} $num";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(_selectedCountry.digits),
      ],
      style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: "Ej: ${'3'*_selectedCountry.digits}",
        border: const OutlineInputBorder(),
        prefixIcon: InkWell(
          onTap: _showCountryPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedCountry.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text(
                  _selectedCountry.code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFD1C4E9) : const Color(0xFF673AB7),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20, color: Colors.purple),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey.withOpacity(0.5),
                  margin: const EdgeInsets.only(left: 6, right: 6),
                ),
              ],
            ),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor ingrese el número de teléfono';
        }
        final clean = value.trim();
        if (!RegExp(r'^[0-9]+$').hasMatch(clean)) {
          return 'Solo se permiten números';
        }
        if (clean.length != _selectedCountry.digits) {
          return 'En ${_selectedCountry.name} debe tener exactamente ${_selectedCountry.digits} dígitos';
        }
        return null;
      },
      onChanged: widget.onChanged,
    );
  }
}
