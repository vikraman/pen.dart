part of pen;

@NgComponent(
    selector: 'pen-editor',
    templateUrl: 'packages/pen/src/pen-editor.html',
    publishAs: 'pen')

  class Editor extends NgShadowRootAware {

    @NgTwoWay('content')
      String content;
    @NgOneWay('rendered')
      String rendered;

    bool isSaved = false;
    dom.ShadowRoot editorElement;
    dom.HtmlElement contentElement;

    void onShadowRoot(dom.ShadowRoot shadowRoot) {
      editorElement = shadowRoot;
    }

    void onEdit() {
      isSaved = false;
    }

    void onSave() {
      if (editorElement == null) return;
      contentElement = editorElement.querySelector('#pen-content');
      if (contentElement == null) return;
      content = contentElement.innerHtml;
      isSaved = true;
      _render();
    }

    void _render() {
      String text =
        content.replaceAll(
            new RegExp(r'(<br>)|(<br\s*\/>)|(<p>)|(<\/p>)'), '\r\n');
      Match m =
        new RegExp(r'\s*(<div>)*\s*\[\s*:markdown\s*:\s*\]\s*')
        .matchAsPrefix(text);
      rendered = m == null ?
        _renderAsHtml(text) : _renderAsMarkdown(text.substring(m.end));
    }

    static String _renderAsHtml(String text) {
      return text;
    }

    static String _renderAsMarkdown(String text) {
      dom.DivElement tmp =
        new dom.DivElement()
        ..setInnerHtml(text);
      return markdownToHtml(tmp.text);
    }
  }

@NgDirective(
    selector: '[ng-bind-html-unsafe]')

  class NgBindHtmlUnsafeDirective {
    final dom.Element element;

    final dom.NodeValidator validator =
      new dom.NodeValidatorBuilder.common()
      ..allowHtml5(uriPolicy: new MyUriPolicy())
      ..allowImages(new MyUriPolicy())
      ..allowInlineStyles()
      ..allowNavigation(new MyUriPolicy());

    NgBindHtmlUnsafeDirective(this.element);

    @NgOneWay('ng-bind-html-unsafe')
      set value(value) =>
      element.setInnerHtml(
          value == null ? '' : value,
          validator: validator);
  }

class MyUriPolicy implements dom.UriPolicy {
  bool allowsUri(String uri) => true;
}