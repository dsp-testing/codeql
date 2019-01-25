/**
 * Provides classes for working with Vue code.
 */

import javascript
import semmle.javascript.security.dataflow.DomBasedXss

module Vue {
  /**
   * Gets a reference to the 'Vue' object.
   */
  DataFlow::SourceNode vue() {
    result = DataFlow::globalVarRef("Vue")
    or
    result = DataFlow::moduleImport("vue")
  }

  /**
   * A call to `vue.extend`.
   */
  private class VueExtend extends DataFlow::CallNode {
    VueExtend() { this = vue().getAMemberCall("extend") }
  }

  private newtype TInstance =
    MkVueInstance(DataFlow::NewNode def) { def = vue().getAnInstantiation() } or
    MkExtendedVue(VueExtend extend) or
    MkExtendedInstance(VueExtend extend, DataFlow::NewNode sub) {
      sub = extend.getAnInstantiation()
    } or
    MkComponent(DataFlow::CallNode def) { def = vue().getAMemberCall("component") } or
    MkSingleFileComponent(VueFile file)

  /**
   * A Vue instance definition.
   *
   * This includes both explicit instantiations of Vue objects, and
   * implicit instantiations in the form of components or Vue
   * extensions that have not yet been instantiated to a Vue instance.
   *
   * The following instances are recognized:
   *   - `new Vue({...})`
   *   - `Vue.extend({...})`
   *   - `new ExtendedVue({...})`
   *   - `Vue.component("my-component", {...})`
   *   - single file components in .vue files
   */
  abstract class Instance extends TInstance {
    /** Gets a textual representation of this element. */
    abstract string toString();

    /**
     * Holds if this element is at the specified location.
     * The location spans column `startcolumn` of line `startline` to
     * column `endcolumn` of line `endline` in file `filepath`.
     * For more information, see
     * [LGTM locations](https://lgtm.com/help/ql/locations).
     */
    predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      filepath = "" and
      startline = 0 and
      startcolumn = 0 and
      endline = 0 and
      endcolumn = 0
    }

    /**
     * Gets the node for option `name` for this instance, this does not include
     * those from extended objects and mixins.
     */
    abstract DataFlow::Node getOwnOption(string name);

    /**
     * Gets the node for option `name` for this instance, including those from
     * extended objects and mixins.
     */
    DataFlow::Node getOption(string name) {
      result = getOwnOption(name)
      or
      exists(DataFlow::SourceNode extendsVal | extendsVal.flowsTo(getOwnOption("extends")) |
        result = extendsVal.(DataFlow::ObjectLiteralNode).getAPropertyWrite(name).getRhs()
        or
        exists(ExtendedVue extend |
          MkExtendedVue(extendsVal) = extend and
          result = extend.getOption(name)
        )
      )
      or
      exists(DataFlow::ArrayCreationNode mixins, DataFlow::ObjectLiteralNode mixin |
        mixins.flowsTo(getOwnOption("mixins")) and
        mixin.flowsTo(mixins.getAnElement()) and
        result = mixin.getAPropertyWrite(name).getRhs()
      )
    }

    /**
     * Gets the node for the `data` option object of this instance.
     */
    DataFlow::Node getData() {
      exists(DataFlow::Node data | data = getOption("data") |
        result = data
        or
        // a constructor variant is available for all instance definitions
        exists(DataFlow::FunctionNode f |
          f.flowsTo(data) and
          result = f.getAReturn()
        )
      )
    }

    /**
     * Gets the node for the `template` option of this instance.
     */
    DataFlow::Node getTemplate() { result = getOption("template") }

    /**
     * Gets the node for the `render` option of this instance.
     */
    DataFlow::Node getRender() { result = getOption("render") }

    /**
     * Gets the node for the `methods` option of this instance.
     */
    DataFlow::Node getMethods() { result = getOption("methods") }

    /**
     * Gets the node for the `computed` option of this instance.
     */
    DataFlow::Node getComputed() { result = getOption("computed") }

    /**
     * Gets a node for a member of the `methods` option of this instance.
     */
    private DataFlow::Node getAMethod() {
      exists(DataFlow::SourceNode methods |
        methods.flowsTo(getMethods()) and
        result = methods.getAPropertyWrite().getRhs()
      )
    }

    /**
     * Gets a node for a member of the `computed` option of this instance that matches `kind` ("get" or "set").
     */
    private DataFlow::Node getAnAccessor(string kind) {
      exists(DataFlow::SourceNode computedObj, DataFlow::Node accessorObjOrGetter |
        computedObj.flowsTo(getComputed()) and
        computedObj.getAPropertyWrite().getRhs() = accessorObjOrGetter |
        result = accessorObjOrGetter and kind = "get"
        or
        exists (DataFlow::SourceNode accessorObj |
          accessorObj.flowsTo(accessorObjOrGetter) and
          result = accessorObj.getAPropertyWrite(kind).getRhs()
        )
      )
    }

    /**
     * Gets a node for a member `name` of the `computed` option of this instance that matches `kind` ("get" or "set").
     */
    private DataFlow::Node getAccessor(string name, string kind) {
      exists(DataFlow::SourceNode computedObj, DataFlow::SourceNode accessorObjOrGetter |
        computedObj.flowsTo(getComputed()) and
        accessorObjOrGetter.flowsTo(computedObj.getAPropertyWrite(name).getRhs())
        |
        result = accessorObjOrGetter and kind = "get" or
        exists (DataFlow::SourceNode accessorObj |
          accessorObj.flowsTo(accessorObjOrGetter) and
          result = accessorObj.getAPropertyWrite(kind).getRhs()
        )
      )
    }

    /**
     * Gets the node for the life cycle hook of the `hookName` option of this instance.
     */
    private DataFlow::Node getALifecycleHook(string hookName) {
      (
        hookName = "beforeCreate" or
        hookName = "created" or
        hookName = "beforeMount" or
        hookName = "mounted" or
        hookName = "beforeUpdate" or
        hookName = "updated" or
        hookName = "activated" or
        hookName = "deactivated" or
        hookName = "beforeDestroy" or
        hookName = "destroyed" or
        hookName = "errorCaptured"
      ) and
      result = getOption(hookName)
    }

    /**
     * Gets a node for a function that will be invoked with `this` bound to this instance.
     */
    DataFlow::Node getABoundFunction() {
      result = getAMethod()
      or
      result = getAnAccessor(_)
      or
      result = getALifecycleHook(_)
    }

    /**
     * Gets a node for the value for property `name` of this instance.
     */
    DataFlow::Node getAPropertyValue(string name) {
      exists(DataFlow::SourceNode obj | obj.getAPropertyWrite(name).getRhs() = result |
        obj.flowsTo(getData())
        or
        exists(DataFlow::FunctionNode bound |
          bound.flowsTo(getABoundFunction()) and
          not bound.getFunction() instanceof ArrowFunctionExpr and
          obj = bound.getReceiver()
        )
      )
      or
      exists(DataFlow::FunctionNode getter |
        getter.flowsTo(getAccessor(name, "get")) and
        result = getter.getAReturn()
      )
    }
  }

  /**
   * A Vue instance from `new Vue({...})`.
   */
  class VueInstance extends Instance, MkVueInstance {
    DataFlow::NewNode def;

    VueInstance() { this = MkVueInstance(def) }

    override string toString() { result = def.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      def.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }

    override DataFlow::Node getOwnOption(string name) { result = def.getOptionArgument(0, name) }

  }

  /**
   * An extended Vue from `Vue.extend({...})`.
   */
  class ExtendedVue extends Instance, MkExtendedVue {
    VueExtend extend;

    ExtendedVue() { this = MkExtendedVue(extend) }

    override string toString() { result = extend.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      extend.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }

    override DataFlow::Node getOwnOption(string name) { result = extend.getOptionArgument(0, name) }

  }

  /**
   * An instance of an extended Vue, for example `instance` of `var Ext = Vue.extend({...}); var instance = new Ext({...})`.
   */
  class ExtendedInstance extends Instance, MkExtendedInstance {
    VueExtend extend;

    DataFlow::NewNode sub;

    ExtendedInstance() { this = MkExtendedInstance(extend, sub) }

    override string toString() { result = sub.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      sub.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }

    override DataFlow::Node getOwnOption(string name) { result = sub.getOptionArgument(0, name) }

    override DataFlow::Node getOption(string name) {
      result = Instance.super.getOption(name)
      or
      result = MkExtendedVue(extend).(ExtendedVue).getOption(name)
    }

  }

  /**
   * A Vue component from `Vue.component("my-component", { ... })`.
   */
  class Component extends Instance, MkComponent {
    DataFlow::CallNode def;

    Component() { this = MkComponent(def) }

    override string toString() { result = def.toString() }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      def.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
    }

    override DataFlow::Node getOwnOption(string name) { result = def.getOptionArgument(1, name) }

  }

  /**
   * A single file Vue component in a `.vue` file.
   */
  class SingleFileComponent extends Instance, MkSingleFileComponent {
    VueFile file;

    SingleFileComponent() { this = MkSingleFileComponent(file) }

    override predicate hasLocationInfo(
      string filepath, int startline, int startcolumn, int endline, int endcolumn
    ) {
      filepath = file.getAbsolutePath() and
      startline = 0 and
      startcolumn = 0 and
      endline = 0 and
      endcolumn = 0
    }

    private Module getModule() {
      exists(HTML::ScriptElement script | script.getFile() = file |
        result.getTopLevel() = script.resolveSource()
        or
        not exists(script.getSourcePath()) and
        // XXX is there no way explicit relation between a script tag and its inline script?
        result.getTopLevel() instanceof InlineScript and
        result.getFile() = script.getFile()
      )
    }

    override DataFlow::Node getOwnOption(string name) {
      // The options of a single file component are defined by the exported object of the script element.
      // Our current module model does not support reads on this object very well, so we use custom steps for the common cases for now.
      exists(Module m, DefiniteAbstractValue abstractOptions |
        any(AnalyzedPropertyWrite write).writes(abstractOptions, name, result) and
        m = getModule()
      |
        // ES2015 exports
        exists(ExportDeclaration export, DataFlow::AnalyzedNode exported |
          export.getEnclosingModule() = m and
          abstractOptions = exported.getAValue()
        |
          exported = export.(BulkReExportDeclaration).getSourceNode("default") or
          exported.asExpr() = export.(ExportDefaultDeclaration).getOperand()
        )
        or
        // Node.js exports
        abstractOptions = m.(NodeModule).getAModuleExportsValue()
      )
    }

    override string toString() { result = file.toString() }
  }

  /**
   * A `.vue` file.
   */
  class VueFile extends File { VueFile() { getExtension() = "vue" } }

}
