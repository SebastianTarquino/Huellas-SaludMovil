import 'package:flutter/material.dart';
import '../pages/pets/pet_history.dart';
import '../../models/pets.dart';
import './petCard.dart';

class PetList extends StatelessWidget {
  final List<Pet> pets;
  final Function(Pet) onPetTap;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const PetList({
    super.key,
    required this.pets,
    required this.onPetTap,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (onLoadMore != null &&
            !isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore!();
        }
        return false;
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: pets.length + (isLoading && hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Indicador de carga al final
                if (index == pets.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pet = pets[index];
                return GestureDetector(
                  onTap: () => onPetTap(pet),
                  child: PetCard(
                    pet: pet,
                    onHistoryTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetHistoryPage(
                            petId: pet.idPet,
                            petName: pet.name,
                          ),
                        ),
                      );
                    },
                    onProcessTap: () =>
                        debugPrint("Proceso activo de ${pet.name}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
