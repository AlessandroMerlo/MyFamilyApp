import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/models/shopping_chart.dart';

class ArticleListNotifier extends StateNotifier<List<Article>> {
  ArticleListNotifier() : super([]);

  bool addArticle(Article article) {
    int indexOf = state.indexWhere((el) => el.name == article.name);

    if (indexOf != -1) {
      return false;
    }
    state = [...state, article];

    return true;
  }

  void removeArticle(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
  }

  bool update(Article article, int index) {
    int indexOf = state.indexWhere((el) => el.name == article.name);

    if (indexOf != -1 && indexOf != index) {
      return false;
    }

    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i] else article
    ];

    return true;
  }

  void addAllArticle(List<Article> articleList) {
    state = articleList;
  }

  void drainList() {
    state = [];
  }
}

final articleListProvider =
    StateNotifierProvider<ArticleListNotifier, List<Article>>(
        (ref) => ArticleListNotifier());
