<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:saxon="http://saxon.sf.net/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://functions"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output encoding="UTF-8" indent="yes" method="xml" version="1.0" name="marc"/>
    <xsl:output encoding="UTF-8" indent="yes" method="xml" version="1.0" name="mods" saxon:next-in-chain="MARC21slim2MODS3-4.xsl"/>
    
    <xsl:function name="f:change-element-ns-deep" as="node()*"
        xmlns:f="http://functions">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="newns" as="xs:string"/>
        <xsl:param name="prefix" as="xs:string"/>
        
        <xsl:for-each select="$nodes">
            <xsl:variable name="node" select="."/>
            <xsl:choose>
                <xsl:when test="$node instance of element()">
                    <xsl:element name="{concat($prefix,
                        if ($prefix = '')
                        then ''
                        else ':',
                        local-name($node))}"
                        namespace="{$newns}">
                        <xsl:sequence select="($node/@*,
                            f:change-element-ns-deep($node/node(),
                            $newns, $prefix))"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$node instance of document-node()">
                    <xsl:document>
                        <xsl:sequence select="f:change-element-ns-deep($node/node(), $newns, $prefix)"/>
                    </xsl:document>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$node"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template match="/">
        <xsl:variable name="in-xml" select="node()" as="node()"/>
        <marc:collection>
            <modsCollection>
                <xsl:for-each select="//collection/record">
                    <xsl:result-document method="xml" encoding="UTF-8" version="1.0" format="marc" href="{replace(base-uri(), '(.*/)(.*)(\.xml|\.json)','$1')}A-{replace(base-uri(), '(.*/)(.*)(\.xml|\.json)','$2')}_{position()}.xml">
                        <marc:record xmlns="http://www.loc.gov/MARC21/slim">
                            <xsl:for-each select="*">
                                <xsl:element name="marc:{name()}">
                                    <xsl:value-of select="$in-xml"/>
                                </xsl:element>
                            </xsl:for-each>
                        </marc:record>
                    </xsl:result-document>
                    <xsl:result-document method="xml" encoding="UTF-8" version="1.0" format="mods" href="{replace(base-uri(), '(.*/)(.*)(\.xml|\.json)','$1')}N-{replace(base-uri(), '(.*/)(.*)(\.xml|\.json)','$2')}_{position()}.xml">
                        <xsl:copy-of select="f:change-element-ns-deep($in-xml,'http://www.loc.gov/MARC21/slim', 'marc')"/>																	
                    </xsl:result-document>
                </xsl:for-each>
            </modsCollection>
        </marc:collection>
    </xsl:template>
    
    
    
</xsl:stylesheet>