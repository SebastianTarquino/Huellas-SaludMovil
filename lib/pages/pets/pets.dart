import 'package:flutter/material.dart';
import '../../models/pets.dart';
import '../../services/pets_services.dart';
import '../../widgets/petList.dart';

class PetHomePage extends StatefulWidget {
  const PetHomePage({super.key});

  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
  final PetService _petService = PetService();
  final List<Pet> _pets = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newPets = await _petService.fetchPet(limit: _limit, offset: _offset);
      setState(() {
        if (newPets.isEmpty) {
          _hasMore = false;
        } else {
          final existingIds = _pets.map((p) => p.idPet).toSet();
          final filtered = newPets.where((p) => !existingIds.contains(p.idPet)).toList();
          _pets.addAll(filtered);
          _offset += _limit;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _onPetTap(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet.name),
        content: Text("Detalles de ${pet.name}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Mascotas")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: PetList(
          pets: _pets,
          onPetTap: _onPetTap,
          isLoading: _isLoading,
          hasMore: _hasMore,
          onLoadMore: _loadPets,
        ),
      ),
    );
  }
}
