<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fhir="http://hl7.org/fhir"
    version="2.0">
    <!-- 
Copyright 2020 Lantana Consulting Group

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
    -->
    <xsl:output method="text"/>
    <xsl:variable name="starting-path" select="//fhir:differential/fhir:element[position()=1]/fhir:path/@value"/>

    <xsl:template match="fhir:StructureDefinition">
        <xsl:call-template name="create-aliases"></xsl:call-template>
        <xsl:apply-templates select="fhir:name"/>
        <xsl:apply-templates select="fhir:type"/>
        <xsl:apply-templates select="fhir:baseDefinition"/>
        <xsl:apply-templates select="fhir:id"/>
        <xsl:apply-templates select="fhir:title"/>
        <xsl:apply-templates select="fhir:description"/>
        <xsl:apply-templates select="fhir:differential"/>
    </xsl:template>
    
    <xsl:template name="create-aliases">
        <xsl:call-template name="create-extension-aliases"></xsl:call-template>
    </xsl:template>
    
    <xsl:template name="create-extension-aliases">
        <xsl:for-each select="//fhir:element[fhir:type/fhir:code/@value='Extension'][fhir:sliceName]">
            <xsl:text>Alias: </xsl:text><xsl:value-of select="fhir:sliceName/@value"/><xsl:text> = </xsl:text><xsl:value-of select="fhir:type/fhir:profile/@value"/><xsl:text>
</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="fhir:name[parent::fhir:StructureDefinition]">
        <xsl:text>Profile: </xsl:text>
        <xsl:value-of select="@value"/>
        <xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="fhir:id[parent::fhir:StructureDefinition]">
        <xsl:text>Id: </xsl:text>
        <xsl:value-of select="@value"/>
        <xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="fhir:type[parent::fhir:StructureDefinition]">
        <xsl:if test="not(following-sibling::fhir:baseDefinition)">
            <xsl:text>Parent: </xsl:text>
            <xsl:value-of select="@value"/>
            <xsl:text>
</xsl:text>
        </xsl:if>
        <!-- otherwise suppress -->
    </xsl:template>

    <xsl:template match="fhir:baseDefinition[parent::fhir:StructureDefinition]">
        <xsl:text>Parent: </xsl:text>
        <xsl:value-of select="@value"/>
        <xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="fhir:title[parent::fhir:StructureDefinition]">
        <xsl:text>Title: "</xsl:text><xsl:value-of select="@value"/>"<xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="fhir:description[parent::fhir:StructureDefinition]">
        <xsl:text>Description: "</xsl:text><xsl:value-of select="@value"/>"<xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="fhir:differential[parent::fhir:StructureDefinition]">
        <xsl:apply-templates select="fhir:element"></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="fhir:element[fhir:path[@value=$starting-path]]" priority="3">
        <xsl:text>// Matched starting-path: </xsl:text><xsl:value-of select="$starting-path"/><xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="fhir:element[ends-with(fhir:path/@value,'extension.url')]" priority="2">
    </xsl:template>
    
    <xsl:template match="fhir:element[fhir:sliceName][fhir:type/fhir:code/@value='Extension']" priority="2">
        <!-- uncomment to add extension support -->
        <xsl:variable name="new-path">
            <xsl:call-template name="fsh-path">
                <xsl:with-param name="temp-path" select="substring-after(@id,'.')"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="trimmed-path">
            <xsl:variable name="slice-part">[<xsl:value-of select="fhir:sliceName/@value"/>]</xsl:variable>
            <xsl:value-of select="substring-before($new-path,$slice-part)"/>
        </xsl:variable>
        <xsl:variable name="id" select="@id"/>
        <xsl:choose>
            <xsl:when test="not(preceding-sibling::fhir:element[fhir:type/fhir:code/@value='Extension'])">
                <xsl:text>* </xsl:text><xsl:value-of select="$trimmed-path"/><xsl:text> contains </xsl:text>
                <xsl:value-of select="fhir:sliceName/@value"/>
                <xsl:text> </xsl:text>
                <xsl:call-template name="cardinality"></xsl:call-template>
                <xsl:if test="fhir:mustSupport/@value='true'"> MS</xsl:if>
                <xsl:text>
</xsl:text>
                <xsl:for-each select="following-sibling::fhir:element[fhir:type/fhir:code/@value='Extension']">
                    <xsl:text>  and </xsl:text>
                    <xsl:value-of select="fhir:sliceName/@value"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="cardinality"></xsl:call-template>
                    <xsl:if test="fhir:mustSupport/@value='true'"> MS</xsl:if>
                    <xsl:text>
</xsl:text>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="fhir:element[fhir:slicing][not(ends-with(fhir:path/@value,'extension'))]" priority="10">
        <xsl:variable name="new-path">
            <xsl:call-template name="fsh-path">
                <xsl:with-param name="temp-path" select="substring-after(@id,'.')"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="id" select="@id"/>
        <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/><xsl:text> ^slicing.discriminator.type = #</xsl:text><xsl:value-of select="fhir:slicing/fhir:discriminator/fhir:type/@value"/><xsl:text>
</xsl:text>
        <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/><xsl:text> ^slicing.discriminator.path = "</xsl:text><xsl:value-of select="fhir:slicing/fhir:discriminator/fhir:path/@value"/><xsl:text>"
</xsl:text>
        <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/><xsl:text> ^slicing.rules = #</xsl:text><xsl:value-of select="fhir:slicing/fhir:rules/@value"/><xsl:text>
</xsl:text>
        <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/><xsl:text> contains </xsl:text>
        <xsl:for-each select="following-sibling::fhir:element[starts-with(@id,$id)]">
            <xsl:if test="not(contains(substring-after(@id,$id),'.'))"><xsl:text>
    </xsl:text>
                <xsl:if test="not(position()=1)"><xsl:text>and </xsl:text></xsl:if>
                <xsl:value-of select="fhir:sliceName/@value"/><xsl:text> </xsl:text>
                <xsl:call-template name="cardinality"/><xsl:if test="fhir:mustSupport/@value='true'"> MS</xsl:if>
            </xsl:if>
        </xsl:for-each><xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="fhir:element[not(fhir:type/fhir:code/@value='Extension')]">
        <xsl:call-template name="basic-element-rule"/>
        <xsl:apply-templates select="fhir:type"></xsl:apply-templates>
        <xsl:apply-templates select="fhir:short"></xsl:apply-templates>
        <xsl:apply-templates select="fhir:definition"></xsl:apply-templates>
        <xsl:apply-templates select="fhir:patternCodeableConcept"></xsl:apply-templates>
        <xsl:apply-templates select="fhir:binding"></xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="fhir:type[fhir:code/@value='Reference']">
        <xsl:variable name="new-path">
            <xsl:call-template name="fsh-path">
                <xsl:with-param name="temp-path" select="substring-after(../@id,'.')"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/><xsl:text> only Reference(</xsl:text>
        <xsl:for-each select="fhir:targetProfile">
            <xsl:if test="not(position()=1)"><xsl:text> | </xsl:text></xsl:if>
            <xsl:value-of select="@value"/>
        </xsl:for-each>
        <xsl:text>)
</xsl:text>
    </xsl:template>
    
    <xsl:template match="fhir:patternCodeableConcept">
        <xsl:variable name="new-path">
            <xsl:call-template name="fsh-path">
                <xsl:with-param name="temp-path" select="substring-after(../@id,'.')"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="fhir:coding">
            <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/><xsl:text> = </xsl:text>
            <xsl:if test="fhir:system">
                <xsl:value-of select="fhir:system/@value"/><xsl:text>#</xsl:text>
            </xsl:if>
            <xsl:if test="fhir:code">
                <xsl:value-of select="fhir:code/@value"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="fhir:binding">
        <xsl:variable name="new-path">
            <xsl:call-template name="fsh-path">
                <xsl:with-param name="temp-path" select="substring-after(../@id,'.')"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/><xsl:text> from </xsl:text><xsl:value-of select="fhir:valueSet/@value"/>
        <xsl:text> (</xsl:text><xsl:value-of select="fhir:strength/@value"/><xsl:text>)
</xsl:text>
    </xsl:template>
    
    <xsl:template match="fhir:short | fhir:definition">
        <xsl:call-template name="text-escape-property">
            <xsl:with-param name="property-name"><xsl:value-of select="local-name(.)"/></xsl:with-param>
            <xsl:with-param name="property-value"><xsl:value-of select="./@value"/></xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="basic-element-rule">
        <xsl:variable name="new-path">
            <xsl:call-template name="fsh-path">
                <xsl:with-param name="temp-path" select="substring-after(@id,'.')"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="cardinality"></xsl:call-template>
        <xsl:if test="fhir:mustSupport/@value='true'"> MS</xsl:if>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    
    <xsl:template name="type-element-rule">
        <xsl:variable name="new-path">
            <xsl:call-template name="fsh-path">
                <xsl:with-param name="temp-path" select="substring-after(@id,'.')"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/>
        <xsl:text> </xsl:text>
        <xsl:if test="fhir:type[fhir:code/@value='Reference']"><xsl:text> only Reference(</xsl:text></xsl:if>
        <xsl:for-each select="fhir:type[fhir:code/@value='Reference']/fhir:targetProfile">
            <xsl:if test="not(position()=1)"><xsl:text> | </xsl:text></xsl:if>
            <xsl:value-of select="@value"/>
        </xsl:for-each>
        <xsl:if test="fhir:type[fhir:code/@value='Reference']"><xsl:text>)</xsl:text></xsl:if>
        <xsl:text>
</xsl:text>
    </xsl:template>
    
    
    <xsl:template name="text-escape-property">
        <xsl:param name="property-name"/>
        <xsl:param name="property-value"/>
        <xsl:variable name="new-path">
            <xsl:call-template name="fsh-path">
                <xsl:with-param name="temp-path" select="substring-after(../@id,'.')"></xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>* </xsl:text><xsl:value-of select="$new-path"/>
        <xsl:text> ^</xsl:text><xsl:value-of select="$property-name"/><xsl:text> = "</xsl:text><xsl:value-of select="$property-value"/><xsl:text>"
</xsl:text>
    </xsl:template>
    
    <!-- May be removed when FSH supports just min or max cardinality vs. requiring both. Currently this is the only thing that requires the snapshot. -->
    <xsl:template name="cardinality">
        <xsl:variable name="id" select="@id"/>
        <xsl:if test="fhir:min or fhir:max">
            <xsl:choose>
                <xsl:when test="fhir:min and fhir:max">
                    <xsl:value-of select="fhir:min/@value"/><xsl:text>..</xsl:text><xsl:value-of select="fhir:max/@value"/>
                </xsl:when>
                <xsl:when test="//fhir:snapshot">
                    <xsl:value-of select="//fhir:snapshot/fhir:element[@id=$id]/fhir:min/@value"/><xsl:text>..</xsl:text><xsl:value-of select="//fhir:snapshot/fhir:element[@id=$id]/fhir:max/@value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>No snapshot found and differential cardinality not fully specified. FSH file may not compile</xsl:message>
                    <xsl:if test="fhir:min">
                        <xsl:value-of select="fhir:min/@value"/>
                    </xsl:if>
                    <xsl:text>..</xsl:text>
                    <xsl:if test="fhir:max">
                        <xsl:value-of select="fhir:max/@value"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="fsh-path">
        <xsl:param name="temp-path"></xsl:param>
        <xsl:choose>
            <xsl:when test="contains($temp-path,':')">
                <xsl:value-of select="substring-before($temp-path,':')"/>
                <xsl:call-template name="convert-slice-path">
                    <xsl:with-param name="slice-segment" select="substring-after($temp-path,':')"></xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$temp-path"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="convert-slice-path">
        <xsl:param name="slice-segment"/>
        <xsl:choose>
            <xsl:when test="contains($slice-segment,'.')">
                <xsl:text>[</xsl:text><xsl:value-of select="substring-before($slice-segment,'.')"/><xsl:text>].</xsl:text>
                <xsl:call-template name="fsh-path">
                    <xsl:with-param name="temp-path" select="substring-after($slice-segment,'.')"></xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>[<xsl:value-of select="$slice-segment"/>]</xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template
        match="fhir:meta | fhir:url | fhir:status | fhir:contact | fhir:fhirVersion | fhir:kind | fhir:abstract | fhir:derivation">
        <!-- suppress -->
    </xsl:template>

    <xsl:template match="*" priority="-10">
        <xsl:text>// </xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>
</xsl:text>
    </xsl:template>


</xsl:stylesheet>
