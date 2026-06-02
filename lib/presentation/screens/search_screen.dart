// [Presentation Layer] — 검색 화면 렌더링 담당
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../../domain/entities/capsule.dart';
import '../theme/app_theme.dart';
import 'capsule_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Capsule> _filtered(List<Capsule> capsules) {
    if (_query.trim().isEmpty) return capsules;
    final q = _query.trim().toLowerCase();
    return capsules
        .where((c) => c.memo.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final capsuleVm = context.watch<CapsuleViewModel>();
    final results = _filtered(capsuleVm.capsules);

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        backgroundColor: AppTheme.warmCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '기억 검색',
          style: GoogleFonts.gaegu(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: GoogleFonts.notoSans(
                  fontSize: 15, color: AppTheme.textDark),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: '기억 속 단어를 검색해보세요 ✦',
                hintStyle: GoogleFonts.gaegu(
                    fontSize: 15, color: AppTheme.textLight),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textLight),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppTheme.textLight, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.warmBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.warmBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // 결과 수
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text(
                    '\'$_query\' 검색 결과 ',
                    style: GoogleFonts.notoSans(
                        fontSize: 13, color: AppTheme.textLight),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${results.length}개',
                      style: GoogleFonts.gaegu(
                          fontSize: 13,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // 결과 목록
          Expanded(
            child: _query.isEmpty
                ? _buildEmpty('검색어를 입력해주세요')
                : results.isEmpty
                    ? _buildEmpty('검색 결과가 없어요')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _SearchResultCard(
                          capsule: results[index],
                          query: _query,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(message,
              style: GoogleFonts.gaegu(
                  fontSize: 16, color: AppTheme.textMedium)),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Capsule capsule;
  final String query;

  const _SearchResultCard({required this.capsule, required this.query});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('yyyy.MM.dd').format(capsule.createdAt);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CapsuleDetailScreen(capsule: capsule),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.warmBorder),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 + 위치
            Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 12, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(dateStr,
                    style: GoogleFonts.notoSans(
                        fontSize: 11, color: AppTheme.textLight)),
                const SizedBox(width: 10),
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppTheme.textLight),
                const SizedBox(width: 3),
                Text(
                  '${capsule.latitude.toStringAsFixed(3)}, '
                  '${capsule.longitude.toStringAsFixed(3)}',
                  style: GoogleFonts.notoSans(
                      fontSize: 11, color: AppTheme.textLight),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: capsule.isPublic
                        ? AppTheme.primaryLight
                        : AppTheme.warmBeige,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    capsule.isPublic ? '공개' : '비공개',
                    style: GoogleFonts.notoSans(
                      fontSize: 9,
                      color: capsule.isPublic
                          ? AppTheme.primary
                          : AppTheme.textLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 하이라이트 텍스트
            _HighlightText(text: capsule.memo, query: query),
          ],
        ),
      ),
    );
  }
}

/// 검색어 하이라이트
class _HighlightText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: GoogleFonts.gaegu(
              fontSize: 15, color: AppTheme.textDark, height: 1.5),
          maxLines: 3,
          overflow: TextOverflow.ellipsis);
    }

    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(lowerQ, start);
      if (idx == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: GoogleFonts.gaegu(
              fontSize: 15, color: AppTheme.textDark, height: 1.5),
        ));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(
          text: text.substring(start, idx),
          style: GoogleFonts.gaegu(
              fontSize: 15, color: AppTheme.textDark, height: 1.5),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: GoogleFonts.gaegu(
          fontSize: 15,
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
          height: 1.5,
          backgroundColor: AppTheme.primaryLight,
        ),
      ));
      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
