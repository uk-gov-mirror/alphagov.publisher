function isSupported($scope = document.body) {
  if (!$scope) {
    return false
  }

  return $scope.classList.contains('govuk-frontend-supported')
}

function normaliseDataset(dataset) {
  /** @type {ReturnType<typeof normaliseDataset>} */
  const out = {}

  for (const [key, value] of Object.entries(dataset)) {
    out[key] = normaliseString(value)
  }

  return out
}

function extractConfigByNamespace(configObject, namespace) {
  /** @type {{ [key: string]: unknown }} */
  const newObject = {}

  for (const [key, value] of Object.entries(configObject)) {
    // Split the key into parts, using . as our namespace separator
    const keyParts = key.split('.')

    // Check if the first namespace matches the configured namespace
    if (keyParts[0] === namespace) {
      // Remove the first item (the namespace) from the parts array,
      // but only if there is more than one part (we don't want blank keys!)
      if (keyParts.length > 1) {
        keyParts.shift()
      }

      // Join the remaining parts back together
      const newKey = keyParts.join('.')

      // Add them to our new object
      newObject[newKey] = value
    }
  }

  return newObject
}

function mergeConfigs(...configObjects) {
  /**
   * Function to take nested objects and flatten them to a dot-separated keyed
   * object. Doing this means we don't need to do any deep/recursive merging of
   * each of our objects, nor transform our dataset from a flat list into a
   * nested object.
   *
   * @internal
   * @param {{ [key: string]: unknown }} configObject - Deeply nested object
   * @returns {{ [key: string]: unknown }} Flattened object with dot-separated keys
   */
  function flattenObject(configObject) {
    // Prepare an empty return object
    /** @type {{ [key: string]: unknown }} */
    const flattenedObject = {}

    /**
     * Our flattening function, this is called recursively for each level of
     * depth in the object. At each level we prepend the previous level names to
     * the key using `prefix`.
     *
     * @internal
     * @param {Partial<{ [key: string]: unknown }>} obj - Object to flatten
     * @param {string} [prefix] - Optional dot-separated prefix
     */
    function flattenLoop(obj, prefix) {
      for (const [key, value] of Object.entries(obj)) {
        const prefixedKey = prefix ? `${prefix}.${key}` : key

        // If the value is a nested object, recurse over that too
        if (value && typeof value === 'object') {
          flattenLoop(value, prefixedKey)
        } else {
          // Otherwise, add this value to our return object
          flattenedObject[prefixedKey] = value
        }
      }
    }

    // Kick off the recursive loop
    flattenLoop(configObject)
    return flattenedObject
  }

  // Start with an empty object as our base
  /** @type {{ [key: string]: unknown }} */
  const formattedConfigObject = {}

  // Loop through each of the passed objects
  for (const configObject of configObjects) {
    const obj = flattenObject(configObject)

    // Push their keys one-by-one into formattedConfigObject. Any duplicate
    // keys will override the existing key with the new value.
    for (const [key, value] of Object.entries(obj)) {
      formattedConfigObject[key] = value
    }
  }

  return formattedConfigObject
}

class GOVUKFrontendError extends Error {
  name = 'GOVUKFrontendError'
}

class ElementError extends GOVUKFrontendError {
  name = 'ElementError'

  /**
   * @internal
   * @overload
   * @param {string} message - Element error message
   */

  /**
   * @internal
   * @overload
   * @param {ElementErrorOptions} options - Element error options
   */

  /**
   * @internal
   * @param {string | ElementErrorOptions} messageOrOptions - Element error message or options
   */
  constructor(messageOrOptions) {
    let message = typeof messageOrOptions === 'string' ? messageOrOptions : ''

    // Build message from options
    if (typeof messageOrOptions === 'object') {
      const { componentName, identifier, element, expectedType } =
        messageOrOptions

      // Add prefix and identifier
      message = `${componentName}: ${identifier}`

      // Append reason
      message += element
        ? ` is not of type ${expectedType ?? 'HTMLElement'}`
        : ' not found'
    }

    super(message)
  }
}

function isSupported($scope = document.body) {
  if (!$scope) {
    return false
  }

  return $scope.classList.contains('govuk-frontend-supported')
}

class SupportError extends GOVUKFrontendError {
  name = 'SupportError'

  /**
   * Checks if GOV.UK Frontend is supported on this page
   *
   * @param {HTMLElement | null} [$scope] - HTML element `<body>` checked for browser support
   */
  constructor($scope = document.body) {
    const supportMessage =
      'noModule' in HTMLScriptElement.prototype
        ? 'GOV.UK Frontend initialised without `<body class="govuk-frontend-supported">` from template `<script>` snippet'
        : 'GOV.UK Frontend is not supported in this browser'

    super(
      $scope
        ? supportMessage
        : 'GOV.UK Frontend initialised without `<script type="module">`'
    )
  }
}

/**
 * Base Component class
 *
 * Centralises the behaviours shared by our components
 *
 * @internal
 * @abstract
 */
class GOVUKFrontendComponent {
  /**
   * Constructs a new component, validating that GOV.UK Frontend is supported
   *
   * @internal
   */
  constructor() {
    this.checkSupport()
  }

  /**
   * Validates whether GOV.UK Frontend is supported
   *
   * @private
   * @throws {SupportError} when GOV.UK Frontend is not supported
   */
  checkSupport() {
    if (!isSupported()) {
      throw new SupportError()
    }
  }
}

function normaliseString(value) {
  if (typeof value !== 'string') {
    return value
  }

  const trimmedValue = value.trim()

  if (trimmedValue === 'true') {
    return true
  }

  if (trimmedValue === 'false') {
    return false
  }

  // Empty / whitespace-only strings are considered finite so we need to check
  // the length of the trimmed string as well
  if (trimmedValue.length > 0 && isFinite(Number(trimmedValue))) {
    return Number(trimmedValue)
  }

  return value
}