import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/network/api_exception.dart';
import 'package:azager/core/services/product_service.dart';

class ReviewScreen extends StatefulWidget {
  final String productName;
  final String productId;
  final int orderId;

  const ReviewScreen({
    super.key,
    required this.productName,
    required this.productId,
    this.orderId = 1,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _productService = ProductService();

  int _rating = 3;
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _productService.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _controller.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a short review comment.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _productService.submitProductReview(
        productId: widget.productId,
        orderId: widget.orderId,
        rating: _rating,
        comment: comment,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your review!'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
      setState(() => _isSubmitting = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to submit review right now.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Write a Review',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Product name ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFF0F0F0),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 24,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.productName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Star rating ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'How was your order?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < _rating;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          size: 36,
                          color: const Color(0xFFFFC107),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  _ratingLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Review text ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tell us more',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'It was really...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Poor';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
