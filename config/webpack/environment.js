const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const customConfig = require('./custom')

environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
        $: 'jquery/src/jquery',
        jQuery: 'jquery/src/jquery',
        // "window.jQuery":'jquery/src/jquery',
        // "window.$": "jquery/src/jquery"
    })
)


// Adds window.$ = require('jquery')
// environment.loaders.append('jquery', {
//     test: require.resolve('jquery'),
//     use: [
//         {
//             loader: 'expose-loader',
//             options: '$',
//         },
//     ],
// })


environment.config.merge(customConfig)
module.exports = environment