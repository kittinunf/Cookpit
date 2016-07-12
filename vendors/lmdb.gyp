{
  'targets': [
    {
      'target_name': 'lmdb',
      'type': 'static_library',
      'sources': [
        '<!@(python ../utils/glob.py -d lmdb/libraries/liblmdb -i *.c -e *test*.c *_copy.c)',
      ],
      'cflags': [
        '-Wno-unused-parameter',
      ],
      'cflags!': [
        '-Werror',
      ],
      'xcode_settings': {
        'OTHER_CFLAGS' : [
          '<@(_cflags)'
        ],
        'OTHER_CFLAGS!' : [
          '-Werror',
        ],
      },
      'include_dirs': [
        'lmdb/libraries/liblmdb',
      ],
    },
  ]
}
