"use strict";

function initTeXViewMobile(flutterTeXData) {
    var teXViewElement = document.getElementById('TeXView');
    teXViewElement.innerHTML = '';
    teXViewElement.appendChild(createTeXView(flutterTeXData), teXViewElement, "", false);
    renderTeXView(() => renderCompleted(teXViewElement, "", false));
}

function initTeXViewWeb(iframeContentWindow, iframeId, flutterTeXData) {
    var teXViewElement = iframeContentWindow.document.getElementById('TeXView');
    teXViewElement.innerHTML = '';
    teXViewElement.appendChild(createTeXView(JSON.parse(flutterTeXData), teXViewElement, iframeId, true));
    iframeContentWindow.renderTeXView(() => renderCompleted(teXViewElement, iframeId, true));
}

function createTeXView(rootData, teXViewElement, iframeId, isWeb) {

    var meta = rootData['meta'];
    var data = rootData['data'];
    var id = meta['id']
    var classList = meta['classList'];

    var element = document.createElement(meta['tag']);
    element.classList.add(classList);
    element.setAttribute('style', rootData['style']);
    element.setAttribute('id', id)

    switch (meta['node']) {
        case 'root': {
            element.appendChild(createTeXView(data, teXViewElement, iframeId, isWeb));
            break;
        }
        case 'leaf': {
            if (meta['tag'] === 'img') {
                if (classList === 'tex-view-asset-image') {
                    element.setAttribute('src', '../../../' + data);
                } else {
                    element.setAttribute('src', data);
                    element.addEventListener("load", () =>
                        renderCompleted(teXViewElement, iframeId, isWeb)

                    );
                }
            } else {
                element.innerHTML = data;
            }
            break;
        }
        case 'internal_child': {
            element.appendChild(createTeXView(data, teXViewElement, iframeId, isWeb));
            if (classList === 'tex-view-ink-well') clickManager(iframeId, element, id, rootData['rippleEffect'], isWeb);
            break;
        }

        default: {
            data.forEach(function (childViewData) {
                element.appendChild(createTeXView(childViewData, teXViewElement, iframeId, isWeb));
            });
        }
    }
    return element;
}

function renderCompleted(texViewElement, iframeId, isWeb) {
    let lastHeight;

    function execute() {
        const height = getTeXViewHeight(texViewElement);
        const rendered = lastHeight === height;
        lastHeight = height;

        if (isWeb) {
            OnTeXViewRenderedCallback(height, iframeId);
        } else {
            OnTeXViewRenderedCallback.postMessage(height);
        }

        if (!rendered) {
            console.log('TeXView not fully rendered yet! Retrying in 250ms...');
            setTimeout(() => execute(texViewElement), 250);
        }
    }
    execute();
}

function clickManager(iframeId, element, id, rippleEffect, isWeb) {
    element.addEventListener('click', function (e) {

        if (isWeb) {
            OnTapCallback(id, iframeId);
        } else {
            OnTapCallback.postMessage(id);
        }

        if (rippleEffect) {
            var ripple = document.createElement('div');
            this.appendChild(ripple);
            var d = Math.max(this.clientWidth, this.clientHeight);
            ripple.style.width = ripple.style.height = d + 'px';
            var rect = this.getBoundingClientRect();
            ripple.style.left = e.clientX - rect.left - d / 2 + 'px';
            ripple.style.top = e.clientY - rect.top - d / 2 + 'px';
            ripple.classList.add('ripple');
        }
    });
}

function getTeXViewHeight(view) {
    var height = view.offsetHeight,
        style = window.getComputedStyle(view)
    return ['top', 'bottom']
        .map(function (side) {
            return parseInt(style["margin-" + side]);
        })
        .reduce(function (total, side) {
            return total + side;
        }, height)
}