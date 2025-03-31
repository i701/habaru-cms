const pageTypes = ["api::news-post.news-post", "api::page.page"];
const pageActions = ["create", "update"];

export const contentMiddleware = () => {
	return async (context, next) => {
		// Early return if the document type or action is not valid
		if (
			!pageTypes.includes(context.uid) ||
			!pageActions.includes(context.action)
		) {
			return await next(); // Call the next middleware in the stack
		}

		const { data } = context.params;
		const userId = data.updatedBy || data.createdBy;
		console.log(data);
		console.log("User ID:", userId);

		const result = await next(); // Call the next middleware in the stack

		// Log the changes made to the document

		return result; // Return the result of the middleware chain
	};
};
