<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" media-type="text/html" />

  <xsl:template match="/">

    <html lang="en">
    <head>

      <meta name="author" content="Ashen Gunaratne" />
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />

      <title>BLOBs</title>

      <link rel="stylesheet" href="//cdn.datatables.net/v/dt/dt-1.10.20/r-2.2.3/datatables.min.css" />

      <style><![CDATA[

        table {
          width: 100%;
        }

        table .raw {
          cursor: zoom-out;
        }

        table .readable {
          cursor: zoom-in;
        }

        thead {
          text-align: center;
        }

        tbody .etag,
        tbody .mtime,
        tbody .size {
          text-align: right;
        }

        tbody .etag {
          font-family: monospace;
        }

        tbody .view {
          color: #5A5A5A;
          font-size: small;
          text-decoration: none;
        }

      ]]></style>

      <script src="//cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.slim.min.js" integrity="sha256-pasqAKBDmFT4eHoN2ndd6lN370kFiGUFyTiUHWhU7k8=" crossorigin="anonymous"></script>
      <script src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/moment.min.js" integrity="sha256-4iQZ6BVL4qNKlQ27TExEhBN1HFPvAvAMbFavKKosSWQ=" crossorigin="anonymous"></script>
      <script src="//cdnjs.cloudflare.com/ajax/libs/filesize/6.0.1/filesize.min.js" integrity="sha256-amk5mNO8nIVwP//56pwOHznfY7yUY+ZMTig9hZrO4IM=" crossorigin="anonymous"></script>
      <script src="//cdn.datatables.net/v/dt/dt-1.10.20/r-2.2.3/datatables.min.js"></script>
      <script><![CDATA[

        $(function () {

          $('table').addClass('stripe').DataTable({
            autoWidth: false,
            columnDefs: [
              { targets: 2, width: '9ch' },    // size
              { targets: 3, width: '25ch' },   // last modified
              { targets: 4, width: '64px' },   // md5 checksum
              { targets: 5, width: '32px' }    // sha256 checksum
            ],
            paging: false,
            responsive: {
              details: { renderer: renderer }
            }
          });

          $('tbody .size').attr('data-size', function () {
            return $(this).data('_', this.innerText).text();
          }).text(function (index, text) {
            return filesize(text);
          }).addClass('readable').click(toggle);

          $('tbody .mtime').attr('data-mtime', function () {
            return $(this).data('_', this.innerText).text();
          }).text(function (index, text) {
            return moment.utc(text).fromNow();
          }).addClass('readable').click(toggle);

        });

        var renderer = function customDataRenderer (api, index, columns) {

          var data = $.map(columns, function (column) {

            if (!column.hidden) {
              return undefined;
            }

            return $('<tr />', {
              'html': [
                $('<td />', { class: 'dtr-title', text: column.title, style: 'padding: 0 8px 0 0;' }),
                $('<td />', { class: api.cell(index, column.columnIndex).node().className.concat(' ', 'dtr-data'), html: column.data, style: 'overflow: auto; padding: 0;' })
              ],
              'data-dt-column': column.columnIndex,
              'data-dt-row': column.rowIndex
            });

          });

          return data.length ? $('<table />', { class: 'dtr-details', html: data, style: 'table-layout: fixed;' }) : false;

        };

        var toggle = function toggleRawReadable () {

          var $this = $(this);
          var current = $this.text();

          $this.text($this.data('_')).data('_', current)
            .toggleClass('raw readable');

        };

      ]]></script>

    </head>
    <body>
      <header>
      </header>
      <main>
        <xsl:apply-templates select="/Blobs" />
      </main>
      <footer>
      </footer>
    </body>
    </html>
  </xsl:template>

  <xsl:template match="/Blobs">
    <table>
      <thead>
        <tr>
          <td class="key" colspan="2">Filename</td>
          <td class="size">Size</td>
          <td class="mtime">Last Modification</td>
          <td class="etag">MD5 Checksum</td>
          <td class="etag">SHA256 Checksum</td>
        </tr>
      </thead>
      <tbody>
        <xsl:for-each select="Blob">
          <tr><xsl:apply-templates select="." /></tr>
        </xsl:for-each>
      </tbody>
      <tfoot>
      </tfoot>
    </table>
  </xsl:template>

  <xsl:template match="/Blobs/Blob">

    <td class="key"><xsl:value-of select="Key" /></td>

    <td>
      <xsl:call-template name="actions">
        <xsl:with-param name="key">
          <xsl:value-of select="Key" />
        </xsl:with-param>
      </xsl:call-template>
    </td>

    <td class="size"><xsl:value-of select="Size" /></td>
    <td class="mtime"><xsl:value-of select="LastModified" /></td>
    <td class="etag"><xsl:value-of select="@md5" /></td>
    <td class="etag"><xsl:value-of select="@sha256" /></td>

  </xsl:template>

  <xsl:template name="actions">

    <xsl:param name="key" />

    <xsl:attribute name="data-search">
      <xsl:value-of select="$key" />
    </xsl:attribute>

    <xsl:if test="ends-with($key, '.csv')">
      <xsl:call-template name="raw">
        <xsl:with-param name="key" select="$key" />
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="ends-with($key, '.txt')">
      <xsl:call-template name="raw">
        <xsl:with-param name="key" select="$key" />
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="ends-with($key, '.jpg')">
      <xsl:call-template name="raw">
        <xsl:with-param name="key" select="$key" />
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="ends-with($key, '.svg')">
      <xsl:call-template name="view">
        <xsl:with-param name="key" select="$key" />
        <xsl:with-param name="type" select="'svg'" />
      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <xsl:template name="view">
    <xsl:param name="key" />
    <xsl:param name="type" />
    <a class="view">
      <xsl:attribute name="href">
        <xsl:value-of select="concat('https://render.githubusercontent.com/view/', $type, '?url=https://raw.githubusercontent.com/ashenm/blob/master/', $key)" />
      </xsl:attribute>
      <span>view</span>
    </a>
  </xsl:template>

  <xsl:template name="raw">
    <xsl:param name="key" />
    <a class="view">
      <xsl:attribute name="href">
        <xsl:value-of select="concat('https://raw.githubusercontent.com/ashenm/blob/master/', $key)" />
      </xsl:attribute>
      <span>view</span>
    </a>
  </xsl:template>

</xsl:stylesheet>

<!-- vim: set expandtab shiftwidth=2 syntax=xslt: -->
