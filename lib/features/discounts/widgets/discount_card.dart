import 'package:flutter/material.dart';

import '../models/discount_item.dart';

class DiscountCard extends StatelessWidget {
  final DiscountItem item;
  final VoidCallback? onTap;

  const DiscountCard({super.key, required this.item, this.onTap});

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} ₺';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Üst satır: ürün adı + indirim yüzdesi
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '%${item.discountPercent} İndirim',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                item.marketName,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),

              const SizedBox(height: 12),

              /// Fiyat alanı
              Row(
                children: [
                  Text(
                    _formatPrice(item.oldPrice),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatPrice(item.newPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Kazanç: ${_formatPrice(item.discountAmount)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 18,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Son tarih: ${item.validUntil}',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              if (item.note != null && item.note!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.note!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
