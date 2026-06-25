              decoration: const InputDecoration(
                labelText: 'Observaciones',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
 
            const SizedBox(height: 20),
            // === SECCIÓN: FOTO ===
            _buildSectionHeader('Fotografía', Icons.camera_alt_outlined),
            const SizedBox(height: 12),
 
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  import 'package:flutter/material.dart';

                  import '../../../../simple/in_memory_vaccinations.dart';
                  import '../../../../simple/in_memory_sectors.dart';

                  class VaccinationFormScreen extends StatefulWidget {
                    const VaccinationFormScreen({super.key});

                    @override
                    State<VaccinationFormScreen> createState() => _VaccinationFormScreenState();
                  }

                  class _VaccinationFormScreenState extends State<VaccinationFormScreen> {
                    final _formKey = GlobalKey<FormState>();
                    final _ownerNameCtrl = TextEditingController();
                    final _petNameCtrl = TextEditingController();
                    String? _selectedVaccine;
                    String? _selectedSectorId;
                    bool _isSubmitting = false;

                    final _vaccines = ['Antirrábica', 'Parvovirus', 'Pentavalente', 'Triple Felina'];

                    @override
                    void dispose() {
                      _ownerNameCtrl.dispose();
                      _petNameCtrl.dispose();
                      super.dispose();
                    }

                    void _submit() {
                      if (!_formKey.currentState!.validate()) return;
                      if (_selectedVaccine == null || _selectedSectorId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete vacuna y sector')));
                        return;
                      }

                      setState(() => _isSubmitting = true);

                      InMemoryVaccinations.add(
                        VaccinationSimple(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          ownerName: _ownerNameCtrl.text.trim(),
                          petName: _petNameCtrl.text.trim(),
                          vaccine: _selectedVaccine!,
                          sectorId: _selectedSectorId!,
                        ),
                      );

                      setState(() => _isSubmitting = false);
                      Navigator.pop(context, true);
                    }

                    @override
                    Widget build(BuildContext context) {
                      final sectors = InMemorySectors.all();

                      return Scaffold(
                        appBar: AppBar(title: const Text('Registrar Vacunación')),
                        body: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: ListView(
                              children: [
                                TextFormField(
                                  controller: _ownerNameCtrl,
                                  decoration: const InputDecoration(labelText: 'Nombre del propietario *'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _petNameCtrl,
                                  decoration: const InputDecoration(labelText: 'Nombre de la mascota *'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _selectedVaccine,
                                  decoration: const InputDecoration(labelText: 'Vacuna *'),
                                  items: _vaccines.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                                  onChanged: (v) => setState(() => _selectedVaccine = v),
                                  validator: (v) => v == null ? 'Seleccione una vacuna' : null,
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _selectedSectorId,
                                  decoration: const InputDecoration(labelText: 'Sector *'),
                                  items: sectors.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                                  onChanged: (v) => setState(() => _selectedSectorId = v),
                                  validator: (v) => v == null ? 'Seleccione un sector' : null,
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : _submit,
                                    child: _isSubmitting ? const CircularProgressIndicator() : const Text('Registrar'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }
          ],
        ),
      ),
    );
  }
 
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }
}
 
class _PetTypeButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
 
  const _PetTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}