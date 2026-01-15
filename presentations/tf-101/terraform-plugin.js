// Inject Terraform language support into Reveal.js highlight.js
const originalInit = Reveal.initialize;
Reveal.initialize = function(config) {
    config.highlight = config.highlight || {};
    config.highlight.beforeHighlight = function(hljs) {
        hljs.registerLanguage('terraform', hljsDefineTerraform);
        hljs.registerLanguage('tf', hljsDefineTerraform);
        hljs.registerLanguage('hcl', hljsDefineTerraform);
    };
    return originalInit.call(this, config);
};

// Dummy plugin for mkslides
const TerraformHighlighting = { id: 'terraform-highlighting' };
