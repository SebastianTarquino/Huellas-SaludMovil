import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/pets.dart'; // Asegúrate de importar tu modelo

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback onHistoryTap;
  final VoidCallback onProcessTap;

  const PetCard({
    super.key,
    required this.pet,
    required this.onHistoryTap,
    required this.onProcessTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                // Imagen de la mascota
                CircleAvatar(
                  radius: 30,
                  backgroundImage: pet.mediaFile != null &&
                          pet.mediaFile!.attachment.isNotEmpty
                      ? MemoryImage(base64Decode(pet.mediaFile!.attachment))
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: pet.mediaFile == null ||
                          pet.mediaFile!.attachment.isEmpty
                      ? const Icon(Icons.pets, size: 30, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),

                // Información de la mascota
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text("ESPECIE: ${pet.species ?? 'Desconocido'}"),
                      Text("SEXO: ${pet.sex ?? '-'}"),
                      Text("EDAD: ${pet.age ?? '-'} meses"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onHistoryTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Historial"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onProcessTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Proceso Activo"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
