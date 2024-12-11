// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded affix "><li class="part-title">Introduction Temp</li><li class="chapter-item expanded affix "><li class="part-title">Code Base</li><li class="chapter-item expanded "><a href="data/datastructures.html"><strong aria-hidden="true">1.</strong> Data Structures</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="data/matrix.html"><strong aria-hidden="true">1.1.</strong> Matrices</a></li><li class="chapter-item expanded "><a href="data/tables.html"><strong aria-hidden="true">1.2.</strong> Tables</a></li><li class="chapter-item expanded "><a href="data/alist.html"><strong aria-hidden="true">1.3.</strong> Adjacency List</a></li><li class="chapter-item expanded "><a href="data/alg.html"><strong aria-hidden="true">1.4.</strong> Linear Algebra</a></li></ol></li><li class="chapter-item expanded "><a href="rng/rng.html"><strong aria-hidden="true">2.</strong> Random Numbers</a></li><li class="chapter-item expanded "><a href="board/board.html"><strong aria-hidden="true">3.</strong> Board</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="board/layout.html"><strong aria-hidden="true">3.1.</strong> Layout in Memory</a></li><li class="chapter-item expanded "><a href="board/rot.html"><strong aria-hidden="true">3.2.</strong> Rotation and Player Orientation</a></li><li class="chapter-item expanded "><a href="board/actions.html"><strong aria-hidden="true">3.3.</strong> Player Actions</a></li><li class="chapter-item expanded "><a href="board/display.html"><strong aria-hidden="true">3.4.</strong> Display</a></li></ol></li><li class="chapter-item expanded "><a href="ints/ints.html"><strong aria-hidden="true">4.</strong> Interrupts</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="ints/timer.html"><strong aria-hidden="true">4.1.</strong> Timer Handler</a></li><li class="chapter-item expanded "><a href="ints/uart.html"><strong aria-hidden="true">4.2.</strong> UART Handler</a></li><li class="chapter-item expanded "><a href="ints/gpio.html"><strong aria-hidden="true">4.3.</strong> GPIO Handler</a></li></ol></li><li class="chapter-item expanded "><a href="game/game.html"><strong aria-hidden="true">5.</strong> Game</a></li><li class="chapter-item expanded affix "><li class="part-title">Documentation</li><li class="chapter-item expanded "><a href="docs/book.html"><strong aria-hidden="true">6.</strong> mdBook</a></li><li class="chapter-item expanded "><a href="docs/labor.html"><strong aria-hidden="true">7.</strong> Division Labor</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString();
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
