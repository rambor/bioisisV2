const path = require('path');

module.exports = {
    module: {
        rules: [
            {
                test: require.resolve('blueimp-file-upload/js/jquery.fileupload.js'),
                use: [
                    {
                        loader: 'imports-loader',
                        options: {
                            imports: {
                                moduleName: 'blueimp-file-upload',
                                name: 'fileupload',
                            },
                            additionalCode:
                                'var define = false;',
                        },
                    },
                ],
            },
            // {
            //     test: require.resolve('jquery'),
            //     use: [{ loader: 'expose-loader', options: 'jQuery' },
            //         { loader: 'expose-loader', options: '$' }]
            // },
        ],
    },
};
